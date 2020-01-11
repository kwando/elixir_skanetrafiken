defmodule Skanetrafiken.Parser do
  import SweetXml

  def parse_getstartendpointresult(content) do
    doc = SweetXml.parse(content)

    start_points =
      doc
      |> xpath(~x"//StartPoints/Point"el)
      |> Enum.map(fn doc ->
        doc
        |> xmap(
          Id: ~x"./Id/text()"i,
          Name: ~x"./Name/text()"s,
          Type: ~x"./Type/text()"s,
          X: ~x"./X/text()"i,
          Y: ~x"./Y/text()"i
        )
        |> Map.put(:__struct__, Skanetrafiken.Point)
      end)

    {:ok, start_points}
  end

  def parse_stationresults(content) do
    lines =
      SweetXml.stream_tags(content, :Line)
      |> Stream.map(fn {:Line, line} ->
        %Skanetrafiken.Line{
          Name: line |> xpath(~x"./Name/text()"s),
          No: line |> xpath(~x"./No/text()"i),
          StopPoint: line |> xpath(~x"./StopPoint/text()"s),
          Towards: line |> xpath(~x"./Towards/text()"s),
          JourneyDateTime:
            line
            |> xpath(~x"./JourneyDateTime/text()"s)
            |> NaiveDateTime.from_iso8601!(),
          Realtime: line |> xpath(~x"./RealTime"e) |> parse_realtimeinfo(),
          Deviations: line |> xpath(~x"./Deviations/Deviation"el) |> parse_deviations(),
          RunNo: line |> xpath(~x"./RunNo/text()"i),
          IsTimingPoint: line |> xpath(~x"./IsTimingPoint/text()"s) |> to_boolean(),
          LineTypeId: line |> xpath(~x"./LineTypeId/text()"i),
          LineTypeName: line |> xpath(~x"./LineTypeName/text()"s)
        }
      end)
      |> Enum.to_list()

    {:ok, lines}
  end

  defp to_boolean("false"), do: false
  defp to_boolean("true"), do: true

  defp parse_realtimeinfo(realtime) do
    xmlElement(realtime, :content)
    |> Enum.reject(&match?({:xmlText, _, _, _, _, _}, &1))
    |> Enum.map(fn realtime ->
      %Skanetrafiken.RealtimeInfo{
        NewDepPoint:
          realtime
          |> xpath(~x"./NewDepPoint/text()"s)
          |> String.trim(),
        DepTimeDeviation:
          realtime
          |> xpath(
            ~x"./DepTimeDeviation/text()"s
            |> Map.put(:cast_to, :integer)
          ),
        DepDeviationAffect:
          realtime
          |> xpath(~x"./DepDeviationAffect/text()"s)
          |> String.trim()
      }
    end)
  end

  defp parse_deviations(deviations) do
    deviations
    |> Enum.map(fn deviation ->
      %Skanetrafiken.Deviation{
        PublicNote:
          deviation
          |> xpath(~x"./PublicNote/text()"s),
        Header:
          deviation
          |> xpath(~x"./Header/text()"s),
        ShortText:
          deviation
          |> xpath(~x"./ShortText/text()"s),
        Summary:
          deviation
          |> xpath(~x"./Summary/text()"s),
        Importance:
          deviation
          |> xpath(~x"./Importance/text()"i),
        Urgency:
          deviation
          |> xpath(~x"./Urgency/text()"i),
        Influence:
          deviation
          |> xpath(~x"./Influence/text()"i)
      }
    end)
  end
end
