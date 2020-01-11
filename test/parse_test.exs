defmodule ParseTest do
  use ExUnit.Case

  test "parsing station results" do
    example1 = File.read!("test/examples/stationresults.xml")

    {:ok, result} = Skanetrafiken.Parser.parse_stationresults(example1)

    line = hd(result)

    assert %Skanetrafiken.Line{
             name: "8",
             no: 8,
             stopPoint: "C",
             towards: "Hyllie",
             journeyDateTime: ~N[2020-01-11T10:58:00],
             realtime: [],
             deviations: [],
             isTimingPoint: false,
             lineTypeId: 4,
             lineTypeName: "Stadsbuss",
             runNo: 363
           } == line
  end

  test "parsing station results 2" do
    example1 = File.read!("test/examples/stationresults2.xml")

    {:ok, result} = Skanetrafiken.Parser.parse_stationresults(example1)

    [first_line, second_line | _] = result

    assert %Skanetrafiken.Line{
             name: "100",
             no: 100,
             stopPoint: "I",
             towards: "Falsterbo",
             journeyDateTime: ~N[2020-01-11 11:22:00],
             realtime: [
               %Skanetrafiken.RealtimeInfo{
                 newDepPoint: "I",
                 depTimeDeviation: 1,
                 depDeviationAffect: "NON_CRITICAL"
               }
             ],
             deviations: [],
             runNo: 163,
             isTimingPoint: true,
             lineTypeId: 1,
             lineTypeName: "Regionbuss"
           } == first_line

    assert %Skanetrafiken.Line{
             name: "5",
             no: 5,
             stopPoint: "D",
             towards: "Västra hamnen via Dockan",
             journeyDateTime: ~N[2020-01-11 11:23:00],
             realtime: [
               %Skanetrafiken.RealtimeInfo{
                 newDepPoint: "D",
                 depTimeDeviation: 1,
                 depDeviationAffect: "NON_CRITICAL"
               }
             ],
             deviations: [
               %Skanetrafiken.Deviation{
                 header: "Stängd hållplats Malmö C läge D",
                 importance: 3,
                 influence: 3,
                 publicNote:
                   "P.g.a. vägarbete är Malmö C läge D stängt för linje 5 mellan 12/1 kl. 5.30-31/1 kl. 15.00. Under denna period får linje 5 i riktning mot Fullriggaren sluthållplats på Malmö C, vid ett tillfälligt läge på Norra Vallgatan. Starthållplats i riktning mot Sten",
                 shortText:
                   "Bussen stannar ej vid Malmö C pga vägarbete. Hänvisning till övr. hpl.\nGäller 2020-01-10 kl 7:00 - 2020-01-31 kl 15:00.",
                 summary:
                   "P.g.a. vägarbete är Malmö C läge D stängt för linje 5 mellan 12/1 kl. 5.30-31/1 kl. 15.00. Under denna period får linje 5 i riktning mot Fullriggaren sluthållplats på Malmö C, vid ett tillfälligt läge på Norra Vallgatan. Starthållplats i riktning mot Stenkällan blir Anna Lindhs plats läge B. ",
                 urgency: 1
               }
             ],
             isTimingPoint: true,
             lineTypeId: 4,
             lineTypeName: "Stadsbuss",
             runNo: 408
           } == second_line
  end

  test "parse query station" do
    example = File.read!("test/examples/querystation.xml")
    {:ok, result} = Skanetrafiken.Parser.parse_getstartendpointresult(example)

    [first | _] = result

    assert %Skanetrafiken.Point{
             id: 80103,
             name: "Malmö Kronprinsen",
             type: "STOP_AREA",
             x: 6_166_894,
             y: 1_322_152
           } == first
  end
end
