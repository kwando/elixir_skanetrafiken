defmodule Skanetrafiken do
  alias Skanetrafiken.Parser
  require Logger

  def search_times(station) do
    with {:ok, %{body: body}} <-
           HTTPoison.get(
             "http://www.labs.skanetrafiken.se/v2.2/stationresults.asp?selPointFrKey=#{
               to_point_id(station)
             }"
           ) do
      Parser.parse_stationresults(body)
    end
  end

  def search_station(term) do
    HTTPoison.get("http://www.labs.skanetrafiken.se/v2.2/querystation.asp?inpPointfr=#{term}")
    |> case do
      {:ok, %{body: body}} ->
        try do
          Parser.parse_getstartendpointresult(body)
        catch
          :exit, e ->
            Logger.warn("malformed xml detected\n\n#{body}")
            {:error, {:parse_error, e}}
        end

      error ->
        error
    end
  end

  defmodule Line do
    defstruct [
      :name,
      :no,
      :stopPoint,
      :towards,
      :journeyDateTime,
      :realtime,
      :deviations,
      :isTimingPoint,
      :runNo,
      :lineTypeId,
      :lineTypeName
    ]
  end

  defmodule RealtimeInfo do
    defstruct [:newDepPoint, :depTimeDeviation, :depDeviationAffect]
  end

  defmodule Deviation do
    defstruct [:publicNote, :header, :summary, :shortText, :importance, :influence, :urgency]
  end

  defmodule Point do
    defstruct [:id, :name, :type, :x, :y]
  end

  defp to_point_id(%Point{id: id}), do: id
  defp to_point_id(value) when is_binary(value) or is_number(value), do: value
end
