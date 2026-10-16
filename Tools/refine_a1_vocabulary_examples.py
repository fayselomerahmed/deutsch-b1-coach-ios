#!/usr/bin/env python3
"""Replace generic A1 example frames with distinct real-life usage."""

from __future__ import annotations

import json
import pathlib
import time

from populate_vocabulary_translations import translate


ROOT = pathlib.Path(__file__).resolve().parents[1]
VOCAB_PATH = ROOT / "DeutschB1Coach" / "Resources" / "vocab_a1.json"

REPLACEMENTS = {
    "a1-v-026": "Der Mann an der Kasse lässt mich zuerst bezahlen.",
    "a1-v-027": "Eine Frau fragt mich an der Haltestelle nach dem Weg.",
    "a1-v-028": "Auf dem Paket steht mein Name falsch.",
    "a1-v-029": "Der Taxifahrer fragt nach meiner Adresse.",
    "a1-v-030": "Auf dem Formular wähle ich mein Land aus.",
    "a1-v-031": "Am Wochenende zeigt mir Lea ihre Stadt.",
    "a1-v-032": "Mein Freund bringt mir eine Suppe, weil ich krank bin.",
    "a1-v-033": "Unser Nachbar nimmt meine Pakete an.",
    "a1-v-034": "Der Lehrer erklärt die Aufgabe mit einem Bild.",
    "a1-v-035": "Ein Schüler hat sein Heft im Bus vergessen.",
    "a1-v-036": "Meine Eltern rufen jeden Sonntag an.",
    "a1-v-037": "Mein Bruder repariert heute mein Fahrrad.",
    "a1-v-038": "Meine Schwester holt die Kinder von der Schule ab.",
    "a1-v-039": "Ihr Sohn spielt nach dem Essen Fußball.",
    "a1-v-040": "Unsere Tochter schläft heute bei ihrer Freundin.",
    "a1-v-041": "Mein Ehemann kocht am Freitag das Abendessen.",
    "a1-v-042": "Seine Ehefrau fährt jeden Morgen mit der U-Bahn.",
    "a1-v-043": "Meine Großmutter backt einen Kuchen für meinen Geburtstag.",
    "a1-v-044": "Mein Großvater liest im Garten die Zeitung.",
    "a1-v-045": "Zu Weihnachten kommt die ganze Familie zu uns.",
    "a1-v-046": "Vor dem Haus steht ein rotes Auto.",
    "a1-v-047": "Bitte mach die Tür leise zu; das Baby schläft.",
    "a1-v-048": "Am Morgen öffne ich das Fenster für frische Luft.",
    "a1-v-049": "Das Frühstück steht schon auf dem Tisch.",
    "a1-v-050": "Für den Gast hole ich einen Stuhl aus der Küche.",
    "a1-v-051": "Nach der Nachtschicht gehe ich sofort ins Bett.",
    "a1-v-052": "In der Küche riecht es nach frischem Brot.",
    "a1-v-053": "Das Bad ist besetzt; ich warte kurz.",
    "a1-v-054": "Die Kinder pflanzen Blumen im Garten.",
    "a1-v-055": "Ich finde den Schlüssel in meiner Jackentasche.",
    "a1-v-056": "Nach dem Sport trinke ich eine große Flasche Wasser.",
    "a1-v-057": "Für den Kaffee brauche ich noch etwas Milch.",
    "a1-v-058": "Bei Halsschmerzen trinkt Sara Tee mit Honig.",
    "a1-v-059": "Für die Pause packe ich einen Apfel ein.",
    "a1-v-060": "Die Banane ist schon sehr reif.",
    "a1-v-061": "Wir schneiden die Kartoffeln für die Suppe.",
    "a1-v-062": "Zum Gemüse koche ich heute Reis.",
    "a1-v-063": "Möchten Sie Käse auf Ihrem Brötchen?",
    "a1-v-064": "Im Restaurant bestellt er Fleisch mit Salat.",
    "a1-v-065": "Das Gemüse kommt frisch vom Markt.",
    "a1-v-066": "Der Preis steht unten auf dem Schild.",
    "a1-v-067": "Am Geldautomaten hole ich etwas Geld.",
    "a1-v-068": "Die Fahrkarte kostet drei Euro.",
    "a1-v-069": "An der Kasse bezahle ich mit Karte.",
    "a1-v-070": "Die Einkäufe passen nicht alle in meine Tasche.",
    "a1-v-071": "Der Supermarkt schließt heute schon um acht.",
    "a1-v-072": "Samstags kauft meine Nachbarin Blumen auf dem Markt.",
    "a1-v-073": "Bitte stell die leere Flasche in den Kasten.",
    "a1-v-074": "Für das Rezept brauche ich ein Kilo Tomaten.",
    "a1-v-075": "Nach dem Essen bringt der Kellner die Rechnung.",
    "a1-v-076": "Wegen der Baustelle ist die Straße gesperrt.",
    "a1-v-077": "Wir treffen uns vor dem Bahnhof.",
    "a1-v-078": "Die nächste Haltestelle ist direkt vor dem Krankenhaus.",
    "a1-v-079": "In der Apotheke hole ich mein Medikament ab.",
    "a1-v-080": "Die Bank öffnet montags um neun Uhr.",
    "a1-v-081": "Bei der Post schicke ich ein Paket nach Spanien.",
    "a1-v-082": "Vor der Schule warten viele Eltern auf ihre Kinder.",
    "a1-v-083": "Für Samstag reservieren wir einen Tisch im Restaurant.",
    "a1-v-084": "Im Park füttert ein Kind die Enten.",
    "a1-v-085": "Nach dem Unfall ruft jemand die Polizei.",
    "a1-v-086": "Unser Auto steht heute in der Werkstatt.",
    "a1-v-087": "Mit dem Fahrrad brauche ich nur zehn Minuten zur Arbeit.",
    "a1-v-088": "Die U-Bahn ist morgens oft voll.",
    "a1-v-089": "Die Straßenbahn hält vor dem Rathaus.",
    "a1-v-090": "Das Flugzeug landet um halb sechs.",
    "a1-v-091": "Die Fahrkarte kaufe ich am Automaten.",
    "a1-v-092": "An der roten Ampel müssen wir warten.",
    "a1-v-093": "Ein Passant zeigt uns den Weg zum Museum.",
    "a1-v-094": "Der Fahrer hilft mir mit dem Koffer.",
    "a1-v-095": "Für die Reise packe ich nur einen kleinen Rucksack.",
    "a1-v-096": "Meine Uhr ist stehen geblieben.",
    "a1-v-097": "Die Pizza ist in einer Minute fertig.",
    "a1-v-098": "Die Fahrt dauert ungefähr eine Stunde.",
    "a1-v-099": "Am Abend esse ich mit meinen Freunden.",
    "a1-v-100": "In der Nacht ist die Straße ganz ruhig.",
    "a1-v-101": "Am Montag habe ich einen frühen Arzttermin.",
    "a1-v-102": "Dieses Wochenende besuchen wir meine Tante.",
    "a1-v-103": "Welches Datum steht auf der Einladung?",
    "a1-v-104": "Die genaue Uhrzeit steht in der E-Mail.",
    "a1-v-105": "Im Büro klingelt schon früh das Telefon.",
    "a1-v-106": "Mein Chef erlaubt mir, heute früher zu gehen.",
    "a1-v-107": "Mein Kollege bringt am Freitag Kuchen mit.",
    "a1-v-108": "In der Pause gehen wir kurz an die frische Luft.",
    "a1-v-109": "Der Kochkurs findet jeden Dienstag statt.",
    "a1-v-110": "Für diese Aufgabe brauchen wir nur zehn Minuten.",
    "a1-v-111": "Das Buch liegt auf meinem Nachttisch.",
    "a1-v-112": "Ich schreibe die neue Telefonnummer in mein Heft.",
    "a1-v-113": "Der Stift schreibt nicht mehr.",
    "a1-v-114": "Mein Computer braucht heute sehr lange zum Starten.",
    "a1-v-115": "Nach dem langen Tag tut mir der Kopf weh.",
    "a1-v-116": "Beim Kochen habe ich mich an der Hand geschnitten.",
    "a1-v-117": "Mein linkes Auge ist rot und tut weh.",
    "a1-v-118": "Das Kind hat Wasser im Ohr.",
    "a1-v-119": "Der Zahnarzt bittet mich, den Mund zu öffnen.",
    "a1-v-120": "Nach dem großen Essen ist mein Bauch ganz voll.",
    "a1-v-121": "Vom schweren Koffer tut mir der Rücken weh.",
    "a1-v-122": "Dieses Medikament nehme ich nach dem Frühstück.",
    "a1-v-123": "Der Schmerz im Knie ist heute stärker.",
    "a1-v-124": "Der Krankenwagen bringt ihn ins Krankenhaus.",
    "a1-v-128": "Meine Eltern kommen morgen zu Besuch.",
    "a1-v-162": "Vor der Arbeit dusche ich jeden Morgen.",
    "a1-v-163": "Der Film fängt um acht Uhr an.",
    "a1-v-170": "Die Kinder springen vor Freude in die Luft.",
    "a1-v-171": "Das kleine Kind hat Angst vor dem großen Hund.",
    "a1-v-172": "Meine größte Sorge ist die hohe Miete.",
    "a1-v-173": "Nach der Arbeit habe ich großen Hunger.",
    "a1-v-174": "Beim Wandern bekommen wir schnell Durst.",
    "a1-v-179": "Die Sonne scheint durch das Küchenfenster.",
    "a1-v-180": "Wegen des Regens nehmen wir einen Schirm mit.",
    "a1-v-181": "Die Kinder bauen im Schnee einen kleinen Schneemann.",
    "a1-v-182": "Der Wind macht die Tür immer wieder zu.",
    "a1-v-183": "Eine dunkle Wolke kommt aus dem Westen.",
    "a1-v-184": "Am Morgen liegt die Temperatur bei fünf Grad.",
    "a1-v-185": "Heute sind es draußen nur zwei Grad.",
    "a1-v-190": "Dieses Wort steht nicht in meinem Wörterbuch.",
    "a1-v-191": "Auf der Postkarte steht nur ein kurzer Satz.",
    "a1-v-192": "Zu Hause sprechen die Kinder zwei Sprachen.",
    "a1-v-193": "Die Bestätigung kommt heute per E-Mail.",
    "a1-v-194": "Ich speichere deine Telefonnummer sofort.",
    "a1-v-195": "Auf meine Nachricht bekomme ich schnell eine Antwort.",
    "a1-v-200": "Vor dem Rathaus findet heute ein Wochenmarkt statt.",
    "a1-v-201": "Im Bürgerbüro beantrage ich einen neuen Ausweis.",
    "a1-v-202": "Meine Nummer wird auf dem Bildschirm angezeigt.",
    "a1-v-203": "Die Wartezeit beim Arzt beträgt heute zwanzig Minuten.",
    "a1-v-204": "Für die Anmeldung fehlt noch ein Dokument.",
    "a1-v-205": "Von meinem Pass brauche ich eine Kopie.",
    "a1-v-206": "Ich melde meinen Sohn heute in der Schule an.",
    "a1-v-208": "Meine Tante kommt am Samstag zum Kaffee.",
    "a1-v-209": "Mein Onkel fährt uns morgen zum Flughafen.",
    "a1-v-210": "Mein Cousin wohnt jetzt in derselben Straße.",
    "a1-v-211": "Meine Cousine hat gestern ein Baby bekommen.",
    "a1-v-212": "Der Enkel hilft seinem Großvater im Garten.",
    "a1-v-213": "Zum Frühstück esse ich ein gekochtes Ei.",
    "a1-v-214": "Die heiße Suppe wärmt mich nach dem Spaziergang.",
    "a1-v-215": "Zum Mittagessen mache ich einen Tomatensalat.",
    "a1-v-216": "Das Frühstück ist im Hotel bis zehn Uhr.",
    "a1-v-217": "Zum Mittagessen treffen wir uns in der Kantine.",
    "a1-v-218": "Heute gibt es das Abendessen auf dem Balkon.",
    "a1-v-219": "Ich trinke meinen Kaffee ohne Zucker.",
    "a1-v-220": "In der Suppe fehlt noch etwas Salz.",
    "a1-v-221": "Haben Sie diese Jacke auch in meiner Größe?",
    "a1-v-222": "Die Farbe der Wand gefällt mir nicht.",
    "a1-v-223": "Das kleine Geschäft an der Ecke verkauft Zeitungen.",
    "a1-v-224": "Im Angebot kostet der Kaffee nur vier Euro.",
    "a1-v-225": "Für den Umtausch brauche ich die Quittung.",
    "a1-v-226": "Unser Zug fährt heute von Bahnsteig sieben ab.",
    "a1-v-227": "Am Flughafen gebe ich meinen Koffer ab.",
    "a1-v-228": "Nach dem Konzert nehmen wir ein Taxi nach Hause.",
    "a1-v-229": "Die Ärztin untersucht mein verletztes Bein.",
    "a1-v-230": "Die Praxis ist am Mittwochnachmittag geschlossen.",
    "a1-v-231": "Bewegung ist gut für den Körper.",
    "a1-v-232": "Nach jeder Lektion mache ich eine kurze Pause.",
    "a1-v-233": "Diese Übung mache ich jeden Morgen fünf Minuten.",
    "a1-v-234": "Im Wörterbuch finde ich die richtige Schreibweise.",
    "a1-v-235": "Unsere Klasse macht am Freitag einen Ausflug.",
    "a1-v-236": "Nach dem Essen macht Lea ihre Hausaufgabe.",
    "a1-v-244": "An der Tafel steht der neue Stundenplan.",
    "a1-v-245": "Ich schreibe die Einkaufsliste auf ein Stück Papier.",
    "a1-v-246": "Das Foto ist ein gutes Beispiel für Teamarbeit.",
    "a1-v-247": "Vor der Prüfung schläft Amir nur wenig.",
    "a1-v-248": "Die Kundin stellt eine Frage zum Vertrag.",
    "a1-v-249": "Die Krankenschwester bringt mir ein Glas Wasser.",
    "a1-v-250": "Der Zahnarzt kontrolliert meine Zähne.",
    "a1-v-251": "Seit gestern kratzt mein Hals.",
    "a1-v-252": "Nach dem Fußballspiel kühle ich mein rechtes Bein.",
}

TRANSLATION_OVERRIDES = {
    "a1-v-040": "Our daughter is staying overnight at her friend's house.",
    "a1-v-052": "It smells like fresh bread in the kitchen.",
    "a1-v-073": "Please put the empty bottle in the crate.",
    "a1-v-113": "The pen has run out of ink.",
    "a1-v-163": "The film starts at eight o'clock.",
    "a1-v-216": "Breakfast is served at the hotel until ten o'clock.",
    "a1-v-220": "The soup still needs a little salt.",
    "a1-v-227": "I check in my suitcase at the airport.",
    "a1-v-230": "The doctor's office is closed on Wednesday afternoons.",
    "a1-v-251": "My throat has felt scratchy since yesterday."
}


def main() -> None:
    entries = json.loads(VOCAB_PATH.read_text())
    entries_by_id = {entry["id"]: entry for entry in entries}
    missing = sorted(set(REPLACEMENTS) - set(entries_by_id))
    if missing:
        raise RuntimeError(f"Unknown vocabulary IDs: {missing}")

    items = [(entries_by_id[word_id], sentence) for word_id, sentence in REPLACEMENTS.items()]
    for start in range(0, len(items), 20):
        batch = items[start : start + 20]
        translations = translate([sentence for _, sentence in batch])
        for (entry, sentence), translation in zip(batch, translations, strict=True):
            entry["exampleSentence"] = sentence
            entry["exampleTranslation"] = TRANSLATION_OVERRIDES.get(entry["id"], translation)
        print(f"Refined {min(start + len(batch), len(items))}/{len(items)}")
        time.sleep(0.12)

    VOCAB_PATH.write_text(json.dumps(entries, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
