defmodule Skanetrafiken do
  alias Skanetrafiken.Parser

  def search_times(station) do
    with %{body: body} <-
           HTTPotion.get(
             "http://www.labs.skanetrafiken.se/v2.2/stationresults.asp?selPointFrKey=#{
               to_point_id(station)
             }"
           ) do
      Parser.parse_stationresults(body)
    end
  end

  def search_station(term) do
    with %{body: body} <-
           HTTPotion.get(
             "http://www.labs.skanetrafiken.se/v2.2/querystation.asp?inpPointfr=#{term}"
           ) do
      Parser.parse_getstartendpointresult(body)
    end
  end

  defmodule Line do
    defstruct [
      :Name,
      :No,
      :StopPoint,
      :Towards,
      :JourneyDateTime,
      :Realtime,
      :Deviations,
      :IsTimingPoint,
      :RunNo,
      :LineTypeId,
      :LineTypeName
    ]
  end

  defmodule RealtimeInfo do
    defstruct [:NewDepPoint, :DepTimeDeviation, :DepDeviationAffect]
  end

  defmodule Deviation do
    defstruct [:PublicNote, :Header, :Summary, :ShortText, :Importance, :Influence, :Urgency]
  end

  defmodule Point do
    defstruct [:Id, :Name, :Type, :X, :Y]
  end

  defp to_point_id(%Point{Id: id}), do: id
  defp to_point_id(value) when is_binary(value) or is_number(value), do: value
end
