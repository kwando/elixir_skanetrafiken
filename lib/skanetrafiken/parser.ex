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
          id: ~x"./Id/text()"i,
          name: ~x"./Name/text()"s,
          type: ~x"./Type/text()"s,
          x: ~x"./X/text()"i,
          y: ~x"./Y/text()"i
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
          name: line |> xpath(~x"./Name/text()"s),
          no: line |> xpath(~x"./No/text()"i),
          stopPoint: line |> xpath(~x"./StopPoint/text()"s),
          towards: line |> xpath(~x"./Towards/text()"s),
          journeyDateTime:
            line
            |> xpath(~x"./JourneyDateTime/text()"s)
            |> NaiveDateTime.from_iso8601!(),
          realtime: line |> xpath(~x"./RealTime"e) |> parse_realtimeinfo(),
          deviations: line |> xpath(~x"./Deviations/Deviation"el) |> parse_deviations(),
          runNo: line |> xpath(~x"./RunNo/text()"i),
          isTimingPoint: line |> xpath(~x"./IsTimingPoint/text()"s) |> to_boolean(),
          lineTypeId: line |> xpath(~x"./LineTypeId/text()"i),
          lineTypeName: line |> xpath(~x"./LineTypeName/text()"s)
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
        newDepPoint:
          realtime
          |> xpath(~x"./NewDepPoint/text()"s)
          |> String.trim(),
        depTimeDeviation:
          realtime
          |> xpath(
            ~x"./DepTimeDeviation/text()"s
            |> Map.put(:cast_to, :integer)
          ),
        depDeviationAffect:
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
        publicNote:
          deviation
          |> xpath(~x"./PublicNote/text()"s),
        header:
          deviation
          |> xpath(~x"./Header/text()"s),
        shortText:
          deviation
          |> xpath(~x"./ShortText/text()"s),
        summary:
          deviation
          |> xpath(~x"./Summary/text()"s),
        importance:
          deviation
          |> xpath(~x"./Importance/text()"i),
        urgency:
          deviation
          |> xpath(~x"./Urgency/text()"i),
        influence:
          deviation
          |> xpath(~x"./Influence/text()"i)
      }
    end)
  end
end
