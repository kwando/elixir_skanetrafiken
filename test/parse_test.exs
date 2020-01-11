defmodule ParseTest do
  use ExUnit.Case

  test "parsing station results" do
    example1 = File.read!("test/examples/stationresults.xml")

    {:ok, result} = Skanetrafiken.Parser.parse_stationresults(example1)

    line = hd(result)

    assert %Skanetrafiken.Line{
             Name: "8",
             No: 8,
             StopPoint: "C",
             Towards: "Hyllie",
             JourneyDateTime: ~N[2020-01-11T10:58:00],
             Realtime: [],
             Deviations: [],
             IsTimingPoint: false,
             LineTypeId: 4,
             LineTypeName: "Stadsbuss",
             RunNo: 363
           } == line
  end

  test "parsing station results 2" do
    example1 = File.read!("test/examples/stationresults2.xml")

    {:ok, result} = Skanetrafiken.Parser.parse_stationresults(example1)

    [first_line, second_line | _] = result

    assert %Skanetrafiken.Line{
             Name: "100",
             No: 100,
             StopPoint: "I",
             Towards: "Falsterbo",
             JourneyDateTime: ~N[2020-01-11 11:22:00],
             Realtime: [
               %Skanetrafiken.RealtimeInfo{
                 NewDepPoint: "I",
                 DepTimeDeviation: 1,
                 DepDeviationAffect: "NON_CRITICAL"
               }
             ],
             Deviations: [],
             RunNo: 163,
             IsTimingPoint: true,
             LineTypeId: 1,
             LineTypeName: "Regionbuss"
           } == first_line

    assert %Skanetrafiken.Line{
             Name: "5",
             No: 5,
             StopPoint: "D",
             Towards: "Västra hamnen via Dockan",
             JourneyDateTime: ~N[2020-01-11 11:23:00],
             Realtime: [
               %Skanetrafiken.RealtimeInfo{
                 NewDepPoint: "D",
                 DepTimeDeviation: 1,
                 DepDeviationAffect: "NON_CRITICAL"
               }
             ],
             Deviations: [
               %Skanetrafiken.Deviation{
                 Header: "Stängd hållplats Malmö C läge D",
                 Importance: 3,
                 Influence: 3,
                 PublicNote:
                   "P.g.a. vägarbete är Malmö C läge D stängt för linje 5 mellan 12/1 kl. 5.30-31/1 kl. 15.00. Under denna period får linje 5 i riktning mot Fullriggaren sluthållplats på Malmö C, vid ett tillfälligt läge på Norra Vallgatan. Starthållplats i riktning mot Sten",
                 ShortText:
                   "Bussen stannar ej vid Malmö C pga vägarbete. Hänvisning till övr. hpl.\nGäller 2020-01-10 kl 7:00 - 2020-01-31 kl 15:00.",
                 Summary:
                   "P.g.a. vägarbete är Malmö C läge D stängt för linje 5 mellan 12/1 kl. 5.30-31/1 kl. 15.00. Under denna period får linje 5 i riktning mot Fullriggaren sluthållplats på Malmö C, vid ett tillfälligt läge på Norra Vallgatan. Starthållplats i riktning mot Stenkällan blir Anna Lindhs plats läge B. ",
                 Urgency: 1
               }
             ],
             IsTimingPoint: true,
             LineTypeId: 4,
             LineTypeName: "Stadsbuss",
             RunNo: 408
           } == second_line
  end

  test "parse query station" do
    example = File.read!("test/examples/querystation.xml")
    {:ok, result} = Skanetrafiken.Parser.parse_getstartendpointresult(example)

    [first | _] = result

    assert %Skanetrafiken.Point{
             Id: 80103,
             Name: "Malmö Kronprinsen",
             Type: "STOP_AREA",
             X: 6_166_894,
             Y: 1_322_152
           } == first
  end
end
