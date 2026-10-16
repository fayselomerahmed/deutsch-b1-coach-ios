const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..", "DeutschB1Coach", "Resources");

const vocabulary = {
  A1: `
Menschen|n|Mann|der|die Männer|man
Menschen|n|Frau|die|die Frauen|woman
Menschen|n|Name|der|die Namen|name
Menschen|n|Adresse|die|die Adressen|address
Menschen|n|Land|das|die Länder|country
Menschen|n|Stadt|die|die Städte|city
Menschen|n|Freund|der|die Freunde|friend
Menschen|n|Nachbar|der|die Nachbarn|neighbor
Menschen|n|Lehrer|der|die Lehrer|teacher
Menschen|n|Schüler|der|die Schüler|student
Familie|n|Eltern|die||parents
Familie|n|Bruder|der|die Brüder|brother
Familie|n|Schwester|die|die Schwestern|sister
Familie|n|Sohn|der|die Söhne|son
Familie|n|Tochter|die|die Töchter|daughter
Familie|n|Ehemann|der|die Ehemänner|husband
Familie|n|Ehefrau|die|die Ehefrauen|wife
Familie|n|Großmutter|die|die Großmütter|grandmother
Familie|n|Großvater|der|die Großväter|grandfather
Familie|n|Familie|die|die Familien|family
Wohnen|n|Haus|das|die Häuser|house
Wohnen|n|Tür|die|die Türen|door
Wohnen|n|Fenster|das|die Fenster|window
Wohnen|n|Tisch|der|die Tische|table
Wohnen|n|Stuhl|der|die Stühle|chair
Wohnen|n|Bett|das|die Betten|bed
Wohnen|n|Küche|die|die Küchen|kitchen
Wohnen|n|Bad|das|die Bäder|bathroom
Wohnen|n|Garten|der|die Gärten|garden
Wohnen|n|Schlüssel|der|die Schlüssel|key
Essen|n|Wasser|das||water
Essen|n|Milch|die||milk
Essen|n|Tee|der|die Tees|tea
Essen|n|Apfel|der|die Äpfel|apple
Essen|n|Banane|die|die Bananen|banana
Essen|n|Kartoffel|die|die Kartoffeln|potato
Essen|n|Reis|der||rice
Essen|n|Käse|der||cheese
Essen|n|Fleisch|das||meat
Essen|n|Gemüse|das||vegetables
Einkaufen|n|Preis|der|die Preise|price
Einkaufen|n|Geld|das||money
Einkaufen|n|Euro|der|die Euro|euro
Einkaufen|n|Kasse|die|die Kassen|checkout
Einkaufen|n|Tasche|die|die Taschen|bag
Einkaufen|n|Supermarkt|der|die Supermärkte|supermarket
Einkaufen|n|Markt|der|die Märkte|market
Einkaufen|n|Flasche|die|die Flaschen|bottle
Einkaufen|n|Kilo|das|die Kilo|kilogram
Einkaufen|n|Rechnung|die|die Rechnungen|bill
Stadt|n|Straße|die|die Straßen|street
Stadt|n|Bahnhof|der|die Bahnhöfe|train station
Stadt|n|Haltestelle|die|die Haltestellen|stop
Stadt|n|Apotheke|die|die Apotheken|pharmacy
Stadt|n|Bank|die|die Banken|bank
Stadt|n|Post|die||post office
Stadt|n|Schule|die|die Schulen|school
Stadt|n|Restaurant|das|die Restaurants|restaurant
Stadt|n|Park|der|die Parks|park
Stadt|n|Polizei|die||police
Verkehr|n|Auto|das|die Autos|car
Verkehr|n|Fahrrad|das|die Fahrräder|bicycle
Verkehr|n|U-Bahn|die|die U-Bahnen|subway
Verkehr|n|Straßenbahn|die|die Straßenbahnen|tram
Verkehr|n|Flugzeug|das|die Flugzeuge|airplane
Verkehr|n|Fahrkarte|die|die Fahrkarten|ticket
Verkehr|n|Ampel|die|die Ampeln|traffic light
Verkehr|n|Weg|der|die Wege|way
Verkehr|n|Fahrer|der|die Fahrer|driver
Verkehr|n|Reise|die|die Reisen|trip
Zeit|n|Uhr|die|die Uhren|clock
Zeit|n|Minute|die|die Minuten|minute
Zeit|n|Stunde|die|die Stunden|hour
Zeit|n|Morgen|der|die Morgen|morning
Zeit|n|Abend|der|die Abende|evening
Zeit|n|Nacht|die|die Nächte|night
Zeit|n|Montag|der|die Montage|Monday
Zeit|n|Wochenende|das|die Wochenenden|weekend
Zeit|n|Datum|das|die Daten|date
Zeit|n|Uhrzeit|die|die Uhrzeiten|time of day
Arbeit|n|Büro|das|die Büros|office
Arbeit|n|Chef|der|die Chefs|boss
Arbeit|n|Kollege|der|die Kollegen|colleague
Arbeit|n|Pause|die|die Pausen|break
Lernen|n|Kurs|der|die Kurse|course
Lernen|n|Aufgabe|die|die Aufgaben|task
Lernen|n|Buch|das|die Bücher|book
Lernen|n|Heft|das|die Hefte|notebook
Lernen|n|Stift|der|die Stifte|pen
Lernen|n|Computer|der|die Computer|computer
Gesundheit|n|Kopf|der|die Köpfe|head
Gesundheit|n|Hand|die|die Hände|hand
Gesundheit|n|Auge|das|die Augen|eye
Gesundheit|n|Ohr|das|die Ohren|ear
Gesundheit|n|Mund|der|die Münder|mouth
Gesundheit|n|Bauch|der|die Bäuche|stomach
Gesundheit|n|Rücken|der|die Rücken|back
Gesundheit|n|Medikament|das|die Medikamente|medicine
Gesundheit|n|Schmerz|der|die Schmerzen|pain
Gesundheit|n|Krankenhaus|das|die Krankenhäuser|hospital
Alltag|v|sein|||to be
Alltag|v|haben|||to have
Alltag|v|gehen|||to go
Alltag|v|kommen|||to come
Alltag|v|wohnen|||to live
Alltag|v|lernen|||to learn
Alltag|v|arbeiten|||to work
Alltag|v|machen|||to do
Alltag|v|kaufen|||to buy
Alltag|v|essen|||to eat
Alltag|v|trinken|||to drink
Alltag|v|lesen|||to read
Alltag|v|schreiben|||to write
Alltag|v|hören|||to hear
Alltag|v|sehen|||to see
Alltag|v|schlafen|||to sleep
Alltag|v|fahren|||to travel
Alltag|v|bleiben|||to stay
Alltag|v|nehmen|||to take
Alltag|v|geben|||to give
Eigenschaften|a|groß|||big
Eigenschaften|a|klein|||small
Eigenschaften|a|gut|||good
Eigenschaften|a|schlecht|||bad
Eigenschaften|a|neu|||new
Eigenschaften|a|alt|||old
Eigenschaften|a|jung|||young
Eigenschaften|a|schön|||beautiful
Eigenschaften|a|kalt|||cold
Eigenschaften|a|warm|||warm
Eigenschaften|a|teuer|||expensive
Eigenschaften|a|billig|||cheap
Eigenschaften|a|schnell|||fast
Eigenschaften|a|langsam|||slow
Eigenschaften|a|freundlich|||friendly
Alltag|v|aufstehen|||to get up
Alltag|v|kochen|||to cook
Alltag|v|duschen|||to shower
Alltag|v|anfangen|||to begin
Alltag|v|öffnen|||to open
Alltag|v|schließen|||to close
Alltag|v|suchen|||to look for
Alltag|v|finden|||to find
Alltag|v|helfen|||to help
Alltag|v|brauchen|||to need
Gefühle|n|Freude|die|die Freuden|joy
Gefühle|n|Angst|die|die Ängste|fear
Gefühle|n|Sorge|die|die Sorgen|worry
Gefühle|n|Hunger|der||hunger
Gefühle|n|Durst|der||thirst
Gefühle|a|glücklich|||happy
Gefühle|a|traurig|||sad
Gefühle|a|nervös|||nervous
Gefühle|a|entspannt|||relaxed
Wetter|n|Sonne|die|die Sonnen|sun
Wetter|n|Regen|der||rain
Wetter|n|Schnee|der||snow
Wetter|n|Wind|der|die Winde|wind
Wetter|n|Wolke|die|die Wolken|cloud
Wetter|n|Temperatur|die|die Temperaturen|temperature
Wetter|n|Grad|das|die Grad|degree
Wetter|a|sonnig|||sunny
Wetter|a|regnerisch|||rainy
Wetter|a|windig|||windy
Wetter|a|trocken|||dry
Kommunikation|n|Wort|das|die Wörter|word
Kommunikation|n|Satz|der|die Sätze|sentence
Kommunikation|n|Sprache|die|die Sprachen|language
Kommunikation|n|E-Mail|die|die E-Mails|email
Kommunikation|n|Telefonnummer|die|die Telefonnummern|phone number
Kommunikation|n|Antwort|die|die Antworten|answer
Kommunikation|v|antworten|||to answer
Kommunikation|v|verstehen|||to understand
Kommunikation|v|buchstabieren|||to spell
Kommunikation|v|wiederholen|||to repeat
Ämter|n|Rathaus|das|die Rathäuser|town hall
Ämter|n|Bürgerbüro|das|die Bürgerbüros|citizens' office
Ämter|n|Nummer|die|die Nummern|number
Ämter|n|Wartezeit|die|die Wartezeiten|waiting time
Ämter|n|Dokument|das|die Dokumente|document
Ämter|n|Kopie|die|die Kopien|copy
Ämter|v|anmelden|||to register
Ämter|v|warten|||to wait
Familie|n|Tante|die|die Tanten|aunt
Familie|n|Onkel|der|die Onkel|uncle
Familie|n|Cousin|der|die Cousins|cousin
Familie|n|Cousine|die|die Cousinen|cousin
Familie|n|Enkel|der|die Enkel|grandson
Essen|n|Brot|das|die Brote|bread
Essen|n|Ei|das|die Eier|egg
Essen|n|Suppe|die|die Suppen|soup
Essen|n|Salat|der|die Salate|salad
Essen|n|Frühstück|das|die Frühstücke|breakfast
Essen|n|Mittagessen|das|die Mittagessen|lunch
Essen|n|Abendessen|das|die Abendessen|dinner
Essen|n|Zucker|der||sugar
Essen|n|Salz|das||salt
Essen|n|Kaffee|der|die Kaffees|coffee
Einkaufen|n|Größe|die|die Größen|size
Einkaufen|n|Farbe|die|die Farben|color
Einkaufen|n|Geschäft|das|die Geschäfte|shop
Einkaufen|n|Angebot|das|die Angebote|offer
Einkaufen|n|Quittung|die|die Quittungen|receipt
Verkehr|n|Bus|der|die Busse|bus
Verkehr|n|Zug|der|die Züge|train
Verkehr|n|Bahnsteig|der|die Bahnsteige|platform
Verkehr|n|Flughafen|der|die Flughäfen|airport
Verkehr|n|Taxi|das|die Taxis|taxi
Gesundheit|n|Arzt|der|die Ärzte|doctor
Gesundheit|n|Ärztin|die|die Ärztinnen|female doctor
Gesundheit|n|Termin|der|die Termine|appointment
Gesundheit|n|Praxis|die|die Praxen|medical practice
Gesundheit|n|Körper|der|die Körper|body
Lernen|n|Lektion|die|die Lektionen|lesson
Lernen|n|Übung|die|die Übungen|exercise
Lernen|n|Wörterbuch|das|die Wörterbücher|dictionary
Lernen|n|Klasse|die|die Klassen|class
Lernen|n|Hausaufgabe|die|die Hausaufgaben|homework
Lernen|n|Tafel|die|die Tafeln|board
Lernen|n|Papier|das|die Papiere|paper
Lernen|n|Beispiel|das|die Beispiele|example
Lernen|n|Prüfung|die|die Prüfungen|exam
Lernen|n|Frage|die|die Fragen|question
Gesundheit|n|Krankenschwester|die|die Krankenschwestern|nurse
Gesundheit|n|Zahnarzt|der|die Zahnärzte|dentist
Gesundheit|n|Hals|der|die Hälse|throat
Gesundheit|n|Bein|das|die Beine|leg
Alltag|v|besuchen|||to visit
Alltag|v|bezahlen|||to pay
Alltag|v|fragen|||to ask
Alltag|v|sagen|||to say
Alltag|v|sprechen|||to speak
Alltag|v|spielen|||to play
Alltag|v|tragen|||to wear or carry
Alltag|v|waschen|||to wash
Alltag|v|putzen|||to clean
Alltag|v|feiern|||to celebrate
`,
  A2: `
Wohnen|n|Miete|die|die Mieten|rent
Wohnen|n|Mieter|der|die Mieter|tenant
Wohnen|n|Vermieter|der|die Vermieter|landlord
Wohnen|n|Umzug|der|die Umzüge|move
Wohnen|n|Möbel|die||furniture
Wohnen|n|Keller|der|die Keller|basement
Wohnen|n|Dach|das|die Dächer|roof
Wohnen|n|Heizung|die|die Heizungen|heating
Wohnen|n|Reparatur|die|die Reparaturen|repair
Wohnen|n|Nachbarschaft|die|die Nachbarschaften|neighborhood
Arbeit|n|Arbeitsplatz|der|die Arbeitsplätze|workplace
Arbeit|n|Arbeitszeit|die|die Arbeitszeiten|working hours
Arbeit|n|Gehalt|das|die Gehälter|salary
Arbeit|n|Lebenslauf|der|die Lebensläufe|CV
Arbeit|n|Vorstellungsgespräch|das|die Vorstellungsgespräche|job interview
Arbeit|n|Erfahrung|die|die Erfahrungen|experience
Arbeit|n|Ausbildung|die|die Ausbildungen|vocational training
Arbeit|n|Schicht|die|die Schichten|shift
Arbeit|n|Kündigung|die|die Kündigungen|termination
Arbeit|n|Besprechung|die|die Besprechungen|meeting
Gesundheit|n|Untersuchung|die|die Untersuchungen|examination
Gesundheit|n|Behandlung|die|die Behandlungen|treatment
Gesundheit|n|Rezept|das|die Rezepte|prescription
Gesundheit|n|Krankenkasse|die|die Krankenkassen|health insurer
Gesundheit|n|Sprechstunde|die|die Sprechstunden|consultation hours
Gesundheit|n|Fieber|das||fever
Gesundheit|n|Husten|der||cough
Gesundheit|n|Erkältung|die|die Erkältungen|cold
Gesundheit|n|Verletzung|die|die Verletzungen|injury
Gesundheit|n|Notfall|der|die Notfälle|emergency
Ämter|n|Behörde|die|die Behörden|authority
Ämter|n|Antrag|der|die Anträge|application
Ämter|n|Bescheinigung|die|die Bescheinigungen|certificate
Ämter|n|Ausweis|der|die Ausweise|identity card
Ämter|n|Pass|der|die Pässe|passport
Ämter|n|Gebühr|die|die Gebühren|fee
Ämter|n|Unterschrift|die|die Unterschriften|signature
Ämter|n|Unterlage|die|die Unterlagen|document
Ämter|n|Frist|die|die Fristen|deadline
Ämter|n|Meldebescheinigung|die|die Meldebescheinigungen|registration certificate
Reisen|n|Unterkunft|die|die Unterkünfte|accommodation
Reisen|n|Reservierung|die|die Reservierungen|reservation
Reisen|n|Abfahrt|die|die Abfahrten|departure
Reisen|n|Ankunft|die|die Ankünfte|arrival
Reisen|n|Verspätung|die|die Verspätungen|delay
Reisen|n|Gepäck|das||luggage
Reisen|n|Ausflug|der|die Ausflüge|excursion
Reisen|n|Sehenswürdigkeit|die|die Sehenswürdigkeiten|sight
Reisen|n|Jugendherberge|die|die Jugendherbergen|hostel
Reisen|n|Fahrplan|der|die Fahrpläne|timetable
Kommunikation|n|Nachricht|die|die Nachrichten|message
Kommunikation|n|Einladung|die|die Einladungen|invitation
Kommunikation|n|Absage|die|die Absagen|cancellation
Kommunikation|n|Vorschlag|der|die Vorschläge|suggestion
Kommunikation|n|Meinung|die|die Meinungen|opinion
Kommunikation|n|Gespräch|das|die Gespräche|conversation
Kommunikation|n|Erklärung|die|die Erklärungen|explanation
Kommunikation|n|Information|die|die Informationen|information
Kommunikation|n|Antwort|die|die Antworten|answer
Kommunikation|n|Fragebogen|der|die Fragebögen|questionnaire
Freizeit|n|Verein|der|die Vereine|club
Freizeit|n|Veranstaltung|die|die Veranstaltungen|event
Freizeit|n|Ausstellung|die|die Ausstellungen|exhibition
Freizeit|n|Konzert|das|die Konzerte|concert
Freizeit|n|Mannschaft|die|die Mannschaften|team
Freizeit|n|Mitglied|das|die Mitglieder|member
Freizeit|n|Hobby|das|die Hobbys|hobby
Freizeit|n|Wanderung|die|die Wanderungen|hike
Freizeit|n|Feier|die|die Feiern|celebration
Freizeit|n|Kultur|die|die Kulturen|culture
Umwelt|n|Müll|der||waste
Umwelt|n|Energie|die|die Energien|energy
Umwelt|n|Strom|der||electricity
Umwelt|n|Verkehrsmittel|das|die Verkehrsmittel|means of transport
Umwelt|n|Natur|die||nature
Umwelt|n|Lärm|der||noise
Umwelt|n|Luft|die||air
Umwelt|n|Umgebung|die|die Umgebungen|surroundings
Umwelt|n|Pfand|das||deposit
Umwelt|n|Recycling|das||recycling
Alltag|v|abholen|||to pick up
Alltag|v|anrufen|||to call
Alltag|v|ausfüllen|||to fill out
Alltag|v|bestellen|||to order
Alltag|v|buchen|||to book
Alltag|v|erklären|||to explain
Alltag|v|erlauben|||to permit
Alltag|v|erzählen|||to tell
Alltag|v|fehlen|||to be absent
Alltag|v|gehören|||to belong
Alltag|v|kündigen|||to terminate
Alltag|v|liefern|||to deliver
Alltag|v|planen|||to plan
Alltag|v|reservieren|||to reserve
Alltag|v|schicken|||to send
Alltag|v|teilnehmen|||to participate
Alltag|v|umziehen|||to move home
Alltag|v|unterschreiben|||to sign
Alltag|v|vereinbaren|||to arrange
Alltag|v|verlängern|||to extend
Alltag|v|verpassen|||to miss
Alltag|v|vorbereiten|||to prepare
Alltag|v|vorschlagen|||to suggest
Alltag|v|wiederholen|||to repeat
Alltag|v|zurückgeben|||to return
Eigenschaften|a|bequem|||comfortable
Eigenschaften|a|beschäftigt|||busy
Eigenschaften|a|dringend|||urgent
Eigenschaften|a|erreichbar|||reachable
Eigenschaften|a|gemeinsam|||together
Eigenschaften|a|gesund|||healthy
Eigenschaften|a|höflich|||polite
Eigenschaften|a|kostenlos|||free of charge
Eigenschaften|a|notwendig|||necessary
Eigenschaften|a|pünktlich|||punctual
Eigenschaften|a|ruhig|||quiet
Eigenschaften|a|schriftlich|||in writing
Eigenschaften|a|verfügbar|||available
Eigenschaften|a|zufrieden|||satisfied
Konnektoren|x|außerdem|||in addition
Konnektoren|x|danach|||afterwards
Konnektoren|x|darum|||therefore
Konnektoren|x|zuerst|||first
Konnektoren|x|während|||while
Wohnen|n|Nebenkosten|die||additional housing costs
Wohnen|n|Hausordnung|die|die Hausordnungen|house rules
Wohnen|n|Kaution|die|die Kautionen|deposit
Wohnen|n|Hausmeister|der|die Hausmeister|caretaker
Wohnen|n|Wohnungsanzeige|die|die Wohnungsanzeigen|apartment listing
Arbeit|n|Bewerbung|die|die Bewerbungen|job application
Arbeit|n|Arbeitgeber|der|die Arbeitgeber|employer
Arbeit|n|Arbeitnehmer|der|die Arbeitnehmer|employee
Arbeit|n|Vertrag|der|die Verträge|contract
Arbeit|n|Überstunde|die|die Überstunden|overtime hour
Arbeit|n|Arbeitslosigkeit|die||unemployment
Gesundheit|n|Versicherung|die|die Versicherungen|insurance
Gesundheit|n|Allergie|die|die Allergien|allergy
Gesundheit|n|Symptom|das|die Symptome|symptom
Gesundheit|n|Genesung|die||recovery
Gesundheit|n|Gesundheitskarte|die|die Gesundheitskarten|health insurance card
Behörden|n|Einwohnermeldeamt|das|die Einwohnermeldeämter|residents' registration office
Behörden|n|Ausländerbehörde|die|die Ausländerbehörden|immigration office
Behörden|n|Verlängerung|die|die Verlängerungen|extension
Behörden|n|Aufenthalt|der|die Aufenthalte|stay
Behörden|n|Vollmacht|die|die Vollmachten|power of attorney
Behörden|n|Original|das|die Originale|original
Behörden|n|Kopie|die|die Kopien|copy
Behörden|n|Aktenzeichen|das|die Aktenzeichen|reference number
Kommunikation|n|Rückfrage|die|die Rückfragen|follow-up question
Kommunikation|n|Bitte|die|die Bitten|request
Kommunikation|n|Zustimmung|die|die Zustimmungen|agreement
Kommunikation|n|Ablehnung|die|die Ablehnungen|rejection
Kommunikation|n|Missverständnis|das|die Missverständnisse|misunderstanding
Kommunikation|v|bestätigen|||to confirm
Kommunikation|v|mitteilen|||to inform
Kommunikation|v|informieren|||to provide information
Alltag|v|erledigen|||to take care of
Alltag|v|wechseln|||to change
Alltag|v|absagen|||to cancel
Alltag|v|verschieben|||to postpone
Alltag|v|überweisen|||to transfer money
Alltag|v|sparen|||to save
Alltag|v|leihen|||to lend or borrow
Alltag|v|sich kümmern|||to take care of
Alltag|v|nachfragen|||to ask again
Alltag|v|abgeben|||to hand in
Eigenschaften|a|zuverlässig|||reliable
Eigenschaften|a|flexibel|||flexible
Eigenschaften|a|vorsichtig|||careful
Eigenschaften|a|praktisch|||practical
Eigenschaften|a|möglich|||possible
Eigenschaften|a|unmöglich|||impossible
Eigenschaften|a|ähnlich|||similar
Eigenschaften|a|unterschiedlich|||different
Wohnen|n|Balkon|der|die Balkone|balcony
Wohnen|n|Schlüsselübergabe|die|die Schlüsselübergaben|key handover
Wohnen|n|Mietvertrag|der|die Mietverträge|rental contract
Wohnen|n|Wohnungsbesichtigung|die|die Wohnungsbesichtigungen|apartment viewing
Wohnen|n|Mangel|der|die Mängel|defect
Arbeit|n|Bewerbungsgespräch|das|die Bewerbungsgespräche|job interview
Arbeit|n|Arbeitszeugnis|das|die Arbeitszeugnisse|employment reference
Arbeit|n|Urlaubstag|der|die Urlaubstage|day of leave
Arbeit|n|Abteilung|die|die Abteilungen|department
Arbeit|n|Teilzeitstelle|die|die Teilzeitstellen|part-time position
Gesundheit|n|Überweisung|die|die Überweisungen|referral
Gesundheit|n|Impfung|die|die Impfungen|vaccination
Gesundheit|n|Blutdruck|der||blood pressure
Gesundheit|n|Nebenwirkung|die|die Nebenwirkungen|side effect
Gesundheit|n|Apotheker|der|die Apotheker|pharmacist
Behörden|n|Terminbestätigung|die|die Terminbestätigungen|appointment confirmation
Behörden|n|Bearbeitungszeit|die|die Bearbeitungszeiten|processing time
Behörden|n|Formular|das|die Formulare|form
Behörden|n|Sprechzeit|die|die Sprechzeiten|office hours
Behörden|n|Sachbearbeiter|der|die Sachbearbeiter|caseworker
Reisen|n|Anschluss|der|die Anschlüsse|connection
Reisen|n|Gleis|das|die Gleise|platform track
Reisen|n|Reiseziel|das|die Reiseziele|travel destination
Reisen|n|Reiseführer|der|die Reiseführer|travel guide
Reisen|n|Hin- und Rückfahrt|die|die Hin- und Rückfahrten|outward and return journey
Kommunikation|n|Auskunft|die|die Auskünfte|information
Kommunikation|n|Rückmeldung|die|die Rückmeldungen|response
Kommunikation|n|Vereinbarung|die|die Vereinbarungen|agreement
Kommunikation|n|Ankündigung|die|die Ankündigungen|announcement
Kommunikation|n|Terminänderung|die|die Terminänderungen|appointment change
Freizeit|n|Eintrittskarte|die|die Eintrittskarten|admission ticket
Freizeit|n|Bücherei|die|die Büchereien|library
Freizeit|n|Sporthalle|die|die Sporthallen|sports hall
Freizeit|n|Kursleiter|der|die Kursleiter|course instructor
Freizeit|n|Treffpunkt|der|die Treffpunkte|meeting point
Alltag|v|sich bewerben|||to apply
Alltag|v|sich entschuldigen|||to apologize
Alltag|v|sich erinnern|||to remember
Alltag|v|sich entscheiden|||to decide
Alltag|v|empfehlen|||to recommend
Alltag|v|vergleichen|||to compare
Alltag|v|vermeiden|||to avoid
Alltag|v|verbessern|||to improve
Alltag|v|beschreiben|||to describe
Alltag|v|sich verabreden|||to arrange to meet
`,
  B1: `
Arbeit|n|Bedingung|die|die Bedingungen|condition
Arbeit|n|Fortbildung|die|die Fortbildungen|professional training
Arbeit|n|Teilzeit|die||part-time work
Arbeit|n|Vollzeit|die||full-time work
Arbeit|n|Verantwortung|die|die Verantwortungen|responsibility
Arbeit|n|Tätigkeit|die|die Tätigkeiten|activity
Arbeit|n|Qualifikation|die|die Qualifikationen|qualification
Arbeit|n|Probezeit|die|die Probezeiten|probation period
Arbeit|n|Arbeitsvertrag|der|die Arbeitsverträge|employment contract
Arbeit|n|Betrieb|der|die Betriebe|company
Gesellschaft|n|Chancengleichheit|die||equal opportunity
Gesellschaft|n|Gemeinschaft|die|die Gemeinschaften|community
Gesellschaft|n|Gewohnheit|die|die Gewohnheiten|habit
Gesellschaft|n|Herkunft|die|die Herkünfte|origin
Gesellschaft|n|Mehrheit|die|die Mehrheiten|majority
Gesellschaft|n|Minderheit|die|die Minderheiten|minority
Gesellschaft|n|Rücksicht|die||consideration
Gesellschaft|n|Unterstützung|die|die Unterstützungen|support
Gesellschaft|n|Verhalten|das||behavior
Gesellschaft|n|Zusammenleben|das||coexistence
Bildung|n|Abschluss|der|die Abschlüsse|qualification
Bildung|n|Kenntnis|die|die Kenntnisse|knowledge
Bildung|n|Fähigkeit|die|die Fähigkeiten|ability
Bildung|n|Lernziel|das|die Lernziele|learning objective
Bildung|n|Prüfungsvorbereitung|die||exam preparation
Bildung|n|Bewertung|die|die Bewertungen|evaluation
Bildung|n|Rückmeldung|die|die Rückmeldungen|feedback
Bildung|n|Fortschritt|der|die Fortschritte|progress
Bildung|n|Zusammenfassung|die|die Zusammenfassungen|summary
Bildung|n|Zusammenhang|der|die Zusammenhänge|connection
Umwelt|n|Klimawandel|der||climate change
Umwelt|n|Nachhaltigkeit|die||sustainability
Umwelt|n|Verbrauch|der||consumption
Umwelt|n|Verschwendung|die|die Verschwendungen|wastefulness
Umwelt|n|Maßnahme|die|die Maßnahmen|measure
Umwelt|n|Auswirkung|die|die Auswirkungen|impact
Umwelt|n|Ressource|die|die Ressourcen|resource
Umwelt|n|Ernährung|die||nutrition
Umwelt|n|Landwirtschaft|die||agriculture
Umwelt|n|Verpackung|die|die Verpackungen|packaging
Medien|n|Datenschutz|der||data protection
Medien|n|Öffentlichkeit|die||public
Medien|n|Bericht|der|die Berichte|report
Medien|n|Beitrag|der|die Beiträge|contribution
Medien|n|Umfrage|die|die Umfragen|survey
Medien|n|Werbung|die|die Werbungen|advertising
Medien|n|Quelle|die|die Quellen|source
Medien|n|Zugang|der|die Zugänge|access
Medien|n|Netzwerk|das|die Netzwerke|network
Medien|n|Veröffentlichung|die|die Veröffentlichungen|publication
Ämter|n|Genehmigung|die|die Genehmigungen|approval
Ämter|n|Widerspruch|der|die Widersprüche|objection
Ämter|n|Verfahren|das|die Verfahren|procedure
Ämter|n|Anspruch|der|die Ansprüche|entitlement
Ämter|n|Nachweis|der|die Nachweise|proof
Ämter|n|Beratung|die|die Beratungen|consultation
Ämter|n|Zuständigkeit|die|die Zuständigkeiten|responsibility
Ämter|n|Regelung|die|die Regelungen|regulation
Ämter|n|Vorschrift|die|die Vorschriften|rule
Ämter|n|Entscheidung|die|die Entscheidungen|decision
Konflikte|n|Missverständnis|das|die Missverständnisse|misunderstanding
Konflikte|n|Lösung|die|die Lösungen|solution
Konflikte|n|Kompromiss|der|die Kompromisse|compromise
Konflikte|n|Beschwerde|die|die Beschwerden|complaint
Konflikte|n|Konsequenz|die|die Konsequenzen|consequence
Konflikte|n|Ursache|die|die Ursachen|cause
Konflikte|n|Standpunkt|der|die Standpunkte|point of view
Konflikte|n|Argument|das|die Argumente|argument
Konflikte|n|Vereinbarung|die|die Vereinbarungen|agreement
Konflikte|n|Entschuldigung|die|die Entschuldigungen|apology
Gesundheit|n|Wohlbefinden|das||well-being
Gesundheit|n|Belastung|die|die Belastungen|strain
Gesundheit|n|Erholung|die||recovery
Gesundheit|n|Vorsorge|die||preventive care
Gesundheit|n|Nebenwirkung|die|die Nebenwirkungen|side effect
Gesundheit|n|Beschwerde|die|die Beschwerden|symptom
Gesundheit|n|Bewegung|die|die Bewegungen|exercise
Gesundheit|n|Schlafmangel|der||lack of sleep
Gesundheit|n|Gleichgewicht|das|die Gleichgewichte|balance
Gesundheit|n|Versorgung|die||care provision
Kommunikation|v|begründen|||to justify
Kommunikation|v|behaupten|||to claim
Kommunikation|v|beschreiben|||to describe
Kommunikation|v|betonen|||to emphasize
Kommunikation|v|diskutieren|||to discuss
Kommunikation|v|empfehlen|||to recommend
Kommunikation|v|erwähnen|||to mention
Kommunikation|v|feststellen|||to determine
Kommunikation|v|überzeugen|||to convince
Kommunikation|v|vergleichen|||to compare
Alltag|v|anerkennen|||to recognize
Alltag|v|beantragen|||to apply for
Alltag|v|berücksichtigen|||to consider
Alltag|v|bewältigen|||to cope with
Alltag|v|einschätzen|||to assess
Alltag|v|entscheiden|||to decide
Alltag|v|ermöglichen|||to enable
Alltag|v|erwarten|||to expect
Alltag|v|fördern|||to promote
Alltag|v|vermeiden|||to avoid
Alltag|v|verzichten|||to do without
Alltag|v|wahrnehmen|||to perceive
Alltag|v|widersprechen|||to disagree
Alltag|v|zustimmen|||to agree
Alltag|v|zusammenfassen|||to summarize
Eigenschaften|a|angemessen|||appropriate
Eigenschaften|a|ausführlich|||detailed
Eigenschaften|a|deutlich|||clear
Eigenschaften|a|entscheidend|||decisive
Eigenschaften|a|erforderlich|||required
Eigenschaften|a|gegenseitig|||mutual
Eigenschaften|a|glaubwürdig|||credible
Eigenschaften|a|langfristig|||long-term
Eigenschaften|a|nachhaltig|||sustainable
Eigenschaften|a|rechtzeitig|||in time
Eigenschaften|a|selbstständig|||independent
Eigenschaften|a|verantwortlich|||responsible
Eigenschaften|a|vorteilhaft|||advantageous
Eigenschaften|a|wesentlich|||essential
Konnektoren|x|allerdings|||however
Konnektoren|x|einerseits|||on the one hand
Konnektoren|x|andererseits|||on the other hand
Konnektoren|x|infolgedessen|||as a result
Konnektoren|x|dennoch|||nevertheless
Prüfung|n|Aufgabenstellung|die|die Aufgabenstellungen|task instructions
Prüfung|n|Hörverstehen|das||listening comprehension
Prüfung|n|Leseverstehen|das||reading comprehension
Prüfung|n|Ausdruck|der|die Ausdrücke|expression
Prüfung|n|Redemittel|das|die Redemittel|useful phrase
Prüfung|n|Zeitmanagement|das||time management
Prüfung|n|Bewertungskriterium|das|die Bewertungskriterien|assessment criterion
Prüfung|n|Lösungsvorschlag|der|die Lösungsvorschläge|proposed solution
Prüfung|n|Einleitung|die|die Einleitungen|introduction
Prüfung|n|Schluss|der|die Schlüsse|conclusion
Prüfung|n|Prüfer|der|die Prüfer|examiner
Prüfung|n|Prüfungsordnung|die|die Prüfungsordnungen|examination regulations
Argumentation|n|Vorteil|der|die Vorteile|advantage
Argumentation|n|Nachteil|der|die Nachteile|disadvantage
Argumentation|n|Begründung|die|die Begründungen|justification
Argumentation|n|Gegenargument|das|die Gegenargumente|counterargument
Argumentation|n|Beispiel|das|die Beispiele|example
Argumentation|n|Schlussfolgerung|die|die Schlussfolgerungen|conclusion
Argumentation|n|Voraussetzung|die|die Voraussetzungen|prerequisite
Argumentation|n|Perspektive|die|die Perspektiven|perspective
Argumentation|n|Priorität|die|die Prioritäten|priority
Argumentation|n|Beleg|der|die Belege|evidence
Argumentation|n|Einwand|der|die Einwände|objection
Argumentation|n|Fazit|das|die Fazits|summary conclusion
Kommunikation|v|erläutern|||to explain in detail
Kommunikation|v|einwenden|||to object
Kommunikation|v|präzisieren|||to clarify precisely
Kommunikation|v|missverstehen|||to misunderstand
Kommunikation|v|sich beziehen|||to refer to
Kommunikation|v|Stellung nehmen|||to state an opinion
Kommunikation|v|widerspiegeln|||to reflect
Kommunikation|v|verdeutlichen|||to clarify
Arbeit|n|Arbeitsbelastung|die|die Arbeitsbelastungen|workload
Arbeit|n|Vereinbarkeit|die||compatibility
Arbeit|n|Beförderung|die|die Beförderungen|promotion
Arbeit|n|Anerkennung|die|die Anerkennungen|recognition
Arbeit|n|Arbeitsklima|das||working atmosphere
Bildung|n|Weiterbildung|die|die Weiterbildungen|continuing education
Bildung|n|Lernstrategie|die|die Lernstrategien|learning strategy
Bildung|n|Selbstständigkeit|die||independence
Bildung|n|Gruppenarbeit|die|die Gruppenarbeiten|group work
Bildung|n|Teilnahmebescheinigung|die|die Teilnahmebescheinigungen|certificate of participation
Gesellschaft|n|Integration|die||integration
Gesellschaft|n|Ehrenamt|das|die Ehrenämter|volunteering
Gesellschaft|n|Vielfalt|die||diversity
Gesellschaft|n|Teilhabe|die||participation
Medien|n|Glaubwürdigkeit|die||credibility
Medien|n|Berichterstattung|die||media coverage
Umwelt|n|Emission|die|die Emissionen|emission
Umwelt|n|erneuerbare Energie|die|die erneuerbaren Energien|renewable energy
Konnektoren|x|sofern|||provided that
Konnektoren|x|sobald|||as soon as
Konnektoren|x|währenddessen|||meanwhile
Konnektoren|x|folglich|||consequently
Konnektoren|x|hingegen|||in contrast
Konnektoren|x|darüber hinaus|||furthermore
Konnektoren|x|somit|||therefore
Konnektoren|x|wohingegen|||whereas
Arbeit|n|Arbeitsrecht|das||employment law
Arbeit|n|Führungskraft|die|die Führungskräfte|manager
Arbeit|n|Weiterbildungsmöglichkeit|die|die Weiterbildungsmöglichkeiten|continuing education opportunity
Arbeit|n|Leistungsdruck|der||performance pressure
Arbeit|n|Teamfähigkeit|die||ability to work in a team
Gesellschaft|n|Zugehörigkeit|die|die Zugehörigkeiten|sense of belonging
Gesellschaft|n|Barriere|die|die Barrieren|barrier
Gesellschaft|n|Diskriminierung|die|die Diskriminierungen|discrimination
Gesellschaft|n|Solidarität|die||solidarity
Gesellschaft|n|Bevölkerung|die|die Bevölkerungen|population
Bildung|n|Lernerfolg|der|die Lernerfolge|learning success
Bildung|n|Kompetenz|die|die Kompetenzen|competence
Bildung|n|Unterrichtsmethode|die|die Unterrichtsmethoden|teaching method
Bildung|n|Prüfungsangst|die||exam anxiety
Bildung|n|Sprachmittlung|die||language mediation
Umwelt|n|Energieverbrauch|der|die Energieverbräuche|energy consumption
Umwelt|n|Abfallvermeidung|die||waste prevention
Umwelt|n|Nahverkehr|der||public transport
Umwelt|n|Umweltbewusstsein|das||environmental awareness
Umwelt|n|Hitzewelle|die|die Hitzewellen|heatwave
Medien|n|Falschmeldung|die|die Falschmeldungen|false report
Medien|n|Meinungsfreiheit|die||freedom of expression
Medien|n|Medienkompetenz|die||media literacy
Medien|n|Nutzerkonto|das|die Nutzerkonten|user account
Medien|n|Bildschirmzeit|die|die Bildschirmzeiten|screen time
Ämter|n|Rechtsberatung|die|die Rechtsberatungen|legal advice
Ämter|n|Bearbeitungsstand|der|die Bearbeitungsstände|processing status
Ämter|n|Datenschutzbestimmung|die|die Datenschutzbestimmungen|data protection provision
Ämter|n|Einspruch|der|die Einsprüche|appeal
Ämter|n|Rechtsmittel|das|die Rechtsmittel|legal remedy
Argumentation|n|Abwägung|die|die Abwägungen|weighing of options
Argumentation|n|Behauptung|die|die Behauptungen|claim
Argumentation|n|Kernargument|das|die Kernargumente|main argument
Argumentation|n|Gegenposition|die|die Gegenpositionen|opposing position
Argumentation|n|Lösungsansatz|der|die Lösungsansätze|proposed approach
Kommunikation|v|nachvollziehen|||to understand or follow
Alltag|v|voraussetzen|||to require or presuppose
Alltag|v|beeinflussen|||to influence
Alltag|v|nachweisen|||to prove
Kommunikation|v|sich auseinandersetzen|||to engage critically with
Kommunikation|v|in Betracht ziehen|||to consider
Kommunikation|v|aufmerksam machen|||to draw attention to
Alltag|v|sich eignen|||to be suitable
Alltag|v|umsetzen|||to implement
Alltag|v|gewährleisten|||to ensure
`
};

function rows(block) {
  return block.trim().split("\n").map(line => {
    const [theme, kind, german, article, plural, english] = line.split("|");
    return { theme, kind, german, article: article || null, plural: plural || null, english };
  });
}

function normalizedGerman(value) {
  return value.toLowerCase().replace(/^(der|die|das)\s+/, "").trim();
}

const lexicalExamples = {
  sein: "Heute bin ich zu Hause.",
  haben: "Ich habe am Nachmittag Zeit.",
  gehen: "Wir gehen zusammen zum Bahnhof.",
  kommen: "Der Bus kommt in fünf Minuten.",
  wohnen: "Ich wohne in einer kleinen Wohnung.",
  lernen: "Wir lernen jeden Abend Deutsch.",
  arbeiten: "Meine Schwester arbeitet im Krankenhaus.",
  machen: "Am Wochenende machen wir einen Ausflug.",
  kaufen: "Ich kaufe frisches Gemüse auf dem Markt.",
  essen: "Die Kinder essen mittags in der Schule.",
  trinken: "Morgens trinke ich gern Tee.",
  lesen: "Im Zug lese ich ein Buch.",
  schreiben: "Bitte schreiben Sie Ihre Adresse hier.",
  hören: "Ich höre jeden Morgen die Nachrichten.",
  sehen: "Vom Fenster sehe ich den Park.",
  schlafen: "Das Kind schläft schon seit acht Uhr.",
  fahren: "Morgen fahre ich mit dem Zug nach Berlin.",
  bleiben: "Heute bleibe ich wegen des Wetters zu Hause.",
  nehmen: "Ich nehme den Bus zur Arbeit.",
  geben: "Kannst du mir bitte den Schlüssel geben?",
  abholen: "Ich hole dich um acht Uhr am Bahnhof ab.",
  anrufen: "Ich rufe morgen bei der Arztpraxis an.",
  ausfüllen: "Bitte füllen Sie das Formular vollständig aus.",
  bestellen: "Wir bestellen zwei Getränke und eine Suppe.",
  buchen: "Ich buche das Hotelzimmer online.",
  erklären: "Die Lehrerin erklärt uns die Aufgabe.",
  erlauben: "Der Vermieter erlaubt uns einen kleinen Hund.",
  erzählen: "Er erzählt seinen Freunden von der Reise.",
  fehlen: "Heute fehlen zwei Teilnehmer im Kurs.",
  gehören: "Der rote Koffer gehört meiner Kollegin.",
  kündigen: "Sie möchte ihren alten Vertrag kündigen.",
  liefern: "Die Firma liefert die Möbel am Freitag.",
  planen: "Wir planen gemeinsam einen Ausflug.",
  reservieren: "Ich reserviere einen Tisch für vier Personen.",
  schicken: "Bitte schicken Sie mir die Unterlagen per E-Mail.",
  teilnehmen: "Nächste Woche nehme ich an einer Fortbildung teil.",
  umziehen: "Im September ziehen wir nach Hamburg um.",
  unterschreiben: "Sie müssen den Antrag unten unterschreiben.",
  vereinbaren: "Ich möchte einen neuen Termin vereinbaren.",
  verlängern: "Kann ich meinen Bibliotheksausweis verlängern?",
  verpassen: "Wegen der Verspätung verpasse ich den Anschluss.",
  vorbereiten: "Wir bereiten uns gründlich auf die Prüfung vor.",
  vorschlagen: "Ich schlage einen Termin am Donnerstag vor.",
  wiederholen: "Könnten Sie den letzten Satz bitte wiederholen?",
  zurückgeben: "Ich gebe das Buch morgen zurück.",
  begründen: "Bitte begründen Sie Ihre Meinung mit einem Beispiel.",
  behaupten: "Der Autor behauptet, dass die Maßnahme wirksam ist.",
  beschreiben: "Beschreiben Sie die Situation möglichst genau.",
  betonen: "Die Ärztin betont die Bedeutung von Bewegung.",
  diskutieren: "Im Kurs diskutieren wir über flexible Arbeitszeiten.",
  empfehlen: "Ich kann Ihnen diesen Sprachkurs empfehlen.",
  erwähnen: "Im Gespräch erwähnt sie ihre Berufserfahrung.",
  feststellen: "Die Werkstatt stellt einen technischen Fehler fest.",
  überzeugen: "Seine klaren Argumente überzeugen die Gruppe.",
  vergleichen: "Wir vergleichen die beiden Angebote miteinander.",
  anerkennen: "Die Behörde erkennt den ausländischen Abschluss an.",
  beantragen: "Sie können die Unterstützung online beantragen.",
  berücksichtigen: "Bei der Planung müssen wir die Kosten berücksichtigen.",
  bewältigen: "Gemeinsam können wir diese schwierige Aufgabe bewältigen.",
  einschätzen: "Ich kann das Risiko noch nicht genau einschätzen.",
  entscheiden: "Der Ausschuss entscheidet nächste Woche über den Antrag.",
  ermöglichen: "Flexible Arbeitszeiten ermöglichen eine bessere Planung.",
  erwarten: "Wir erwarten die Entscheidung bis Ende des Monats.",
  fördern: "Das Projekt fördert den Austausch in der Nachbarschaft.",
  vermeiden: "Mit guter Vorbereitung lassen sich Fehler vermeiden.",
  verzichten: "Ich versuche, im Alltag auf Plastik zu verzichten.",
  wahrnehmen: "Viele Beschäftigte nehmen das Beratungsangebot wahr.",
  widersprechen: "In diesem Punkt muss ich Ihnen widersprechen.",
  zustimmen: "Ich stimme dem Vorschlag grundsätzlich zu.",
  zusammenfassen: "Am Ende fasse ich die wichtigsten Argumente zusammen.",
  groß: "Die neue Wohnung ist groß und hell.",
  klein: "Das Bad ist klein, aber praktisch.",
  gut: "Der Kaffee in diesem Café ist sehr gut.",
  schlecht: "Heute ist das Wetter leider schlecht.",
  neu: "Mein Nachbar hat ein neues Fahrrad.",
  alt: "Das Rathaus ist mehr als hundert Jahre alt.",
  jung: "Die junge Ärztin arbeitet im Krankenhaus.",
  schön: "Der Park ist im Frühling besonders schön.",
  kalt: "Im Winter ist es morgens oft kalt.",
  warm: "Die Suppe ist noch warm.",
  teuer: "Die Fahrkarte ist leider ziemlich teuer.",
  billig: "Auf dem Markt ist das Gemüse billig.",
  schnell: "Der neue Zug ist sehr schnell.",
  langsam: "Bitte sprechen Sie etwas langsamer.",
  freundlich: "Die Mitarbeiterin am Empfang ist sehr freundlich.",
  bequem: "Die Sitze im Zug sind bequem.",
  beschäftigt: "Der Arzt ist gerade beschäftigt.",
  dringend: "Ich brauche dringend einen neuen Termin.",
  erreichbar: "Die Praxis ist vormittags telefonisch erreichbar.",
  gemeinsam: "Wir lösen die Aufgabe gemeinsam.",
  gesund: "Regelmäßige Bewegung hält uns gesund.",
  höflich: "Seine Bitte war klar und höflich formuliert.",
  kostenlos: "Der Eintritt ist für Kinder kostenlos.",
  notwendig: "Für die Anmeldung ist ein Ausweis notwendig.",
  pünktlich: "Der Zug ist heute pünktlich angekommen.",
  ruhig: "Nachts ist es in dieser Straße ruhig.",
  schriftlich: "Bitte bestätigen Sie den Termin schriftlich.",
  verfügbar: "Das gewünschte Zimmer ist noch verfügbar.",
  zufrieden: "Wir sind mit der Beratung sehr zufrieden.",
  angemessen: "Die vorgeschlagene Lösung erscheint mir angemessen.",
  ausführlich: "Der Bericht beschreibt die Ergebnisse ausführlich.",
  deutlich: "Die Sprecherin erklärt ihren Standpunkt deutlich.",
  entscheidend: "Gute Vorbereitung ist für den Erfolg entscheidend.",
  erforderlich: "Für den Antrag ist ein aktueller Nachweis erforderlich.",
  gegenseitig: "In einer Gemeinschaft sollte man sich gegenseitig unterstützen.",
  glaubwürdig: "Die Begründung klingt klar und glaubwürdig.",
  langfristig: "Langfristig möchten wir weniger Energie verbrauchen.",
  nachhaltig: "Die Stadt investiert in nachhaltige Verkehrsmittel.",
  rechtzeitig: "Bitte reichen Sie die Unterlagen rechtzeitig ein.",
  selbstständig: "Nach dem Kurs kann sie die Aufgabe selbstständig lösen.",
  verantwortlich: "Wer ist für diese Entscheidung verantwortlich?",
  vorteilhaft: "Flexible Arbeitszeiten können für Familien vorteilhaft sein.",
  wesentlich: "Vertrauen ist für eine gute Zusammenarbeit wesentlich.",
  außerdem: "Der Kurs ist günstig; außerdem liegt er in der Nähe.",
  danach: "Zuerst füllen Sie das Formular aus, danach unterschreiben Sie es.",
  darum: "Der Zug fällt aus, darum nehme ich den Bus.",
  zuerst: "Zuerst lese ich die Aufgabe ganz genau.",
  während: "Während ich koche, hört meine Tochter Musik.",
  allerdings: "Die Wohnung ist schön, allerdings ist die Miete hoch.",
  einerseits: "Einerseits ist Homeoffice praktisch, andererseits fehlt der Kontakt.",
  andererseits: "Die Stelle ist anspruchsvoll; andererseits bietet sie gute Chancen.",
  infolgedessen: "Die Kosten sind gestiegen; infolgedessen wurde der Plan geändert.",
  dennoch: "Es regnete stark; dennoch fand die Veranstaltung statt."
  ,aufstehen: "An Arbeitstagen stehe ich um sechs Uhr auf."
  ,kochen: "Heute koche ich eine Gemüsesuppe für meine Familie."
  ,duschen: "Nach dem Sport dusche ich immer."
  ,anfangen: "Der Deutschkurs fängt am Montag an."
  ,öffnen: "Bitte öffnen Sie das Fenster."
  ,schließen: "Die Bibliothek schließt um achtzehn Uhr."
  ,suchen: "Ich suche meinen Schlüssel."
  ,finden: "Wo finde ich die nächste Apotheke?"
  ,helfen: "Kannst du mir mit der Tasche helfen?"
  ,brauchen: "Für das Formular brauche ich einen Stift."
  ,glücklich: "Nach der guten Nachricht bin ich sehr glücklich."
  ,traurig: "Das Kind ist traurig, weil sein Freund wegzieht."
  ,nervös: "Vor meinem ersten Kurstag bin ich etwas nervös."
  ,entspannt: "Am Wochenende bin ich zu Hause ganz entspannt."
  ,sonnig: "Morgen wird es warm und sonnig."
  ,regnerisch: "Der Herbst ist hier oft regnerisch."
  ,windig: "An der Küste ist es heute sehr windig."
  ,trocken: "Nach einer Woche ohne Regen ist der Boden trocken."
  ,antworten: "Bitte antworten Sie bis Freitag auf die E-Mail."
  ,verstehen: "Ich verstehe die Frage noch nicht."
  ,buchstabieren: "Können Sie Ihren Nachnamen bitte buchstabieren?"
  ,"A1:wiederholen": "Bitte wiederholen Sie das Wort langsam."
  ,warten: "Wir warten vor dem Bürgerbüro."
  ,anmelden: "Ich melde mich heute für den Sprachkurs an."
  ,bestätigen: "Bitte bestätigen Sie den Termin per E-Mail."
  ,mitteilen: "Die Schule teilt uns den neuen Termin mit."
  ,informieren: "Die Mitarbeiterin informiert mich über die Öffnungszeiten."
  ,erledigen: "Ich erledige die wichtigsten Aufgaben am Vormittag."
  ,wechseln: "Nächsten Monat wechsle ich die Krankenkasse."
  ,absagen: "Wegen des Fiebers muss ich den Termin absagen."
  ,verschieben: "Können wir die Besprechung auf Dienstag verschieben?"
  ,überweisen: "Ich überweise die Miete am Monatsanfang."
  ,sparen: "Wir sparen für eine längere Reise."
  ,leihen: "Kannst du mir dein Wörterbuch leihen?"
  ,"sich kümmern": "Am Wochenende kümmere ich mich um die Kinder."
  ,nachfragen: "Wenn etwas unklar ist, frage ich noch einmal nach."
  ,abgeben: "Sie können den Antrag am Empfang abgeben."
  ,zuverlässig: "Meine Kollegin ist zuverlässig und immer pünktlich."
  ,flexibel: "Bei diesem Kurs sind die Lernzeiten flexibel."
  ,vorsichtig: "Fahren Sie bei Schnee bitte vorsichtig."
  ,praktisch: "Die neue App ist einfach und praktisch."
  ,möglich: "Ein Termin am Mittwoch ist möglich."
  ,unmöglich: "Ohne Ausweis ist die Anmeldung leider unmöglich."
  ,ähnlich: "Die beiden Wohnungen sind ähnlich groß."
  ,unterschiedlich: "Unsere Arbeitszeiten sind sehr unterschiedlich."
  ,erläutern: "Die Referentin erläutert den Vorschlag an einem konkreten Beispiel."
  ,einwenden: "Ein Teilnehmer wendet ein, dass die Kosten zu hoch sind."
  ,präzisieren: "Im zweiten Absatz präzisiert die Autorin ihre zentrale Aussage."
  ,missverstehen: "Bitte fragen Sie nach, damit Sie die Aufgabe nicht missverstehen."
  ,"sich beziehen": "In meiner Antwort beziehe ich mich auf den letzten Absatz."
  ,"Stellung nehmen": "Im Prüfungsgespräch nehme ich klar zu dem Vorschlag Stellung."
  ,widerspiegeln: "Die Umfrage spiegelt die Erfahrungen vieler Beschäftigter wider."
  ,verdeutlichen: "Eine Grafik verdeutlicht den Unterschied zwischen den Angeboten."
  ,sofern: "Sie können teilnehmen, sofern Sie sich rechtzeitig anmelden."
  ,sobald: "Ich melde mich, sobald die Behörde geantwortet hat."
  ,währenddessen: "Meine Kollegin telefoniert; währenddessen bereite ich die Unterlagen vor."
  ,folglich: "Die Frist ist abgelaufen; folglich muss ein neuer Antrag gestellt werden."
  ,hingegen: "Die erste Lösung ist günstig, die zweite hingegen ist nachhaltiger."
  ,"darüber hinaus": "Der Kurs vermittelt Grammatik und darüber hinaus wichtige Prüfungsstrategien."
  ,somit: "Alle Nachweise liegen vor; somit kann das Verfahren beginnen."
  ,wohingegen: "Im Zentrum sind die Mieten hoch, wohingegen sie am Stadtrand günstiger sind."
  ,besuchen: "Am Sonntag besuche ich meine Großeltern."
  ,bezahlen: "Ich bezahle die Rechnung mit Karte."
  ,fragen: "Ich frage die Lehrerin nach der Hausaufgabe."
  ,sagen: "Bitte sagen Sie mir Ihre Adresse."
  ,sprechen: "Wir sprechen im Kurs jeden Tag Deutsch."
  ,spielen: "Die Kinder spielen nach der Schule im Park."
  ,tragen: "Heute trage ich eine warme Jacke."
  ,waschen: "Am Samstag wasche ich meine Kleidung."
  ,putzen: "Ich putze morgens und abends meine Zähne."
  ,feiern: "Wir feiern meinen Geburtstag mit der Familie."
  ,"sich bewerben": "Sie bewirbt sich um eine Teilzeitstelle."
  ,"sich entschuldigen": "Ich entschuldige mich für die verspätete Antwort."
  ,"sich erinnern": "Ich erinnere mich gut an meinen ersten Kurstag."
  ,"sich entscheiden": "Wir entscheiden uns für die ruhigere Wohnung."
  ,"A2:empfehlen": "Die Ärztin empfiehlt mir mehr Bewegung."
  ,"A2:vergleichen": "Vor der Buchung vergleiche ich mehrere Angebote."
  ,"A2:vermeiden": "Ich fahre früher los, um die Verspätung zu vermeiden."
  ,"A2:beschreiben": "Können Sie den Mangel in der Wohnung genau beschreiben?"
  ,verbessern: "Durch regelmäßiges Üben verbessert er seine Aussprache."
  ,"sich verabreden": "Wir verabreden uns am Samstag vor der Bücherei."
  ,nachvollziehen: "Ich kann Ihre Entscheidung gut nachvollziehen."
  ,voraussetzen: "Die Stelle setzt gute Deutschkenntnisse voraus."
  ,beeinflussen: "Lange Bildschirmzeiten beeinflussen häufig den Schlaf."
  ,nachweisen: "Die Bewerberin muss ihre Qualifikation nachweisen."
  ,"sich auseinandersetzen": "Im Kurs setzen wir uns mit verschiedenen Standpunkten auseinander."
  ,"in Betracht ziehen": "Wir ziehen eine berufliche Weiterbildung in Betracht."
  ,"aufmerksam machen": "Die Kampagne macht auf die Folgen der Verschwendung aufmerksam."
  ,"sich eignen": "Dieses Lernmaterial eignet sich gut für die Prüfungsvorbereitung."
  ,umsetzen: "Das Team setzt den Lösungsvorschlag schrittweise um."
  ,gewährleisten: "Klare Regeln gewährleisten einen fairen Ablauf."
};

const nounContexts = {
  A1: {
    Menschen: "Im Deutschkurs", Familie: "In der Familie", Wohnen: "Beim Thema Wohnen",
    Essen: "Beim Einkaufen", Einkaufen: "Im Supermarkt", Stadt: "Auf dem Stadtplan",
    Verkehr: "Bei der Reiseplanung", Zeit: "Für unseren Termin", Arbeit: "Im Büro",
    Lernen: "Im Unterricht", Gesundheit: "Beim Arzt", Gefühle: "Im Gespräch über Gefühle",
    Wetter: "Im Wetterbericht", Kommunikation: "Im Sprachkurs", Ämter: "Im Bürgerbüro"
  },
  A2: {
    Wohnen: "Bei der Wohnungssuche", Arbeit: "Im Vorstellungsgespräch", Gesundheit: "In der Sprechstunde",
    Ämter: "Bei der Behörde", Reisen: "Bei der Reiseplanung", Kommunikation: "In unserem Gespräch",
    Freizeit: "Bei der Wochenendplanung", Umwelt: "Im Umweltkurs", Behörden: "Beim Behördentermin"
  },
  B1: {
    Arbeit: "In der Teamsitzung", Gesellschaft: "In der gesellschaftlichen Diskussion",
    Bildung: "Im Bildungskurs", Umwelt: "In der Umweltdiskussion", Medien: "Im Medienbericht",
    Ämter: "Im Beratungsgespräch", Konflikte: "Bei der Konfliktlösung", Gesundheit: "Im Gesundheitskurs",
    Argumentation: "In der Diskussion", Prüfung: "Bei der Prüfungsvorbereitung"
  }
};

function accusativePhrase(entry) {
  const articles = { der: "den", die: "die", das: "das" };
  const weakMasculineForms = { Name: "Namen", Nachbar: "Nachbarn", Kollege: "Kollegen" };
  const noun = weakMasculineForms[entry.german] || entry.german;
  return `${articles[entry.article] || entry.article || "das Wort"} ${noun}`;
}

function contextualExample(entry, level) {
  if (lexicalExamples[`${level}:${entry.german}`]) return lexicalExamples[`${level}:${entry.german}`];
  if (lexicalExamples[entry.german]) return lexicalExamples[entry.german];
  if (entry.kind === "n") {
    const context = nounContexts[level]?.[entry.theme] || "Im Deutschkurs";
    const phrase = accusativePhrase(entry);
    const variation = [...entry.german].reduce((sum, character) => sum + character.charCodeAt(0), 0) % 4;
    if (variation === 0) return `${context} sprechen wir über ${phrase}.`;
    if (variation === 1) return `${context} geht es heute um ${phrase}.`;
    if (variation === 2) return `${context} möchte ich mehr über ${phrase} erfahren.`;
    return `${context}: Kannst du etwas über ${phrase} sagen?`;
  }
  if (entry.kind === "v") return `Im Kurs üben wir, wie man „${entry.german}“ richtig verwendet.`;
  if (entry.kind === "a") return `Dieses Beispiel ist ${entry.german}.`;
  return `Im Text verwenden wir „${entry.german}“ als wichtiges Verbindungswort.`;
}

function needsBetterExample(value) {
  return !value || /^(Hier ist|Kannst du heute|Ich möchte mich heute|Die Situation ist|Wir verwenden heute)/.test(value);
}

for (const level of ["A1", "A2", "B1"]) {
  const file = path.join(root, `vocab_${level.toLowerCase()}.json`);
  const current = JSON.parse(fs.readFileSync(file, "utf8"));
  const curatedMaximum = { A1: 25, A2: 5, B1: 5 }[level];
  const seen = new Set(current.map(item => normalizedGerman(item.german)));
  let next = Math.max(...current.map(item => Number(item.id.split("-").pop()))) + 1;

  for (const entry of rows(vocabulary[level])) {
    const existing = current.find(item => normalizedGerman(item.german) === normalizedGerman(entry.german));
    if (existing) {
      const numericId = Number(existing.id.split("-").pop());
      if (numericId > curatedMaximum || needsBetterExample(existing.exampleSentence)) {
        existing.exampleSentence = contextualExample(entry, level);
      }
      continue;
    }
    current.push({
      id: `${level.toLowerCase()}-v-${String(next++).padStart(3, "0")}`,
      level,
      theme: entry.theme,
      german: entry.german,
      article: entry.article,
      plural: entry.plural,
      english: entry.english,
      exampleSentence: contextualExample(entry, level),
      ttsText: entry.article ? `${entry.article} ${entry.german}` : entry.german,
      difficultyTag: level === "B1" ? "exam" : "core"
    });
    seen.add(normalizedGerman(entry.german));
  }

  if (current.length <= 100) throw new Error(`${level} has only ${current.length} words`);
  fs.writeFileSync(file, JSON.stringify(current, null, 2) + "\n");
}

const grammarFile = path.join(root, "grammar.json");
const grammar = JSON.parse(fs.readFileSync(grammarFile, "utf8"));

function addGrammar(level, id, order, title, explanation, examples, mistakes, practices) {
  const topic = {
    id,
    level,
    order,
    title,
    explanation,
    examples: examples.map(([german, english]) => ({ german, english })),
    commonMistakes: mistakes,
    practice: practices.map(([prompt, answer, detail]) => ({ prompt, answer, explanation: detail }))
  };
  const existingIndex = grammar.findIndex(item => item.id === id);
  if (existingIndex >= 0) grammar[existingIndex] = topic;
  else grammar.push(topic);
}

const a1Additional = [
  ["a1-adjectives-predicative", 15, "Adjectives after Sein", "After sein, werden, and bleiben, an adjective describes the subject without an ending. Use the base adjective form even when the noun has a gender.", [["Der Kaffee ist heiß.", "The coffee is hot."], ["Die Kinder sind müde.", "The children are tired."], ["Das Wetter bleibt kalt.", "The weather stays cold."]], ["Adding -e or -er after sein.", "Changing the adjective for plural subjects."], [["Complete: Die Wohnung ist ___. (klein)", "klein", "A predicative adjective after ist has no ending."], ["Translate: The soup is warm.", "Die Suppe ist warm.", "Use the base form warm after sein."], ["Correct: Der Mann ist freundliche.", "Der Mann ist freundlich.", "Without a comparison, use the base adjective freundlich."]]],
  ["a1-coordination", 16, "Connecting Main Clauses", "Use und, aber, oder, and denn to join equal words or main clauses. The normal verb position stays unchanged after these coordinating conjunctions.", [["Ich lerne Deutsch und mein Bruder arbeitet.", "I learn German and my brother works."], ["Möchtest du Tee oder Kaffee?", "Would you like tea or coffee?"], ["Ich komme später, denn der Bus hat Verspätung.", "I am coming later because the bus is delayed."]], ["Sending the verb to the end after denn.", "Using aber when the ideas do not contrast."], [["Complete: Ich bin müde, ___ ich arbeite noch.", "aber", "Aber introduces a contrast."], ["Translate: We can walk or take the bus.", "Wir können zu Fuß gehen oder den Bus nehmen.", "Oder presents alternatives."], ["Correct: Ich bleibe zu Hause, denn ich krank bin.", "Ich bleibe zu Hause, denn ich bin krank.", "Denn joins a main clause, so the verb stays in position two."]]],
  ["a1-time-expressions", 17, "Time, Days, and Dates", "Use um for clock times, am for days and dates, im for months and seasons, and von...bis for a time range.", [["Der Kurs beginnt am Montag um neun Uhr.", "The course begins on Monday at nine o'clock."], ["Im Juli fahren wir nach Hamburg.", "In July we are traveling to Hamburg."], ["Die Praxis ist von acht bis zwölf Uhr geöffnet.", "The practice is open from eight until twelve."]], ["Using am before a clock time.", "Using im before a weekday."], [["Complete: Der Termin ist ___ 14 Uhr.", "um", "Use um for an exact clock time."], ["Translate: in winter", "im Winter", "Seasons commonly use im."], ["Complete: ___ Dienstag ___ Donnerstag", "von Dienstag bis Donnerstag", "Von...bis expresses a range."]]],
  ["a1-accusative-pronouns", 18, "Accusative Personal Pronouns", "Replace a direct object with mich, dich, ihn, sie, es, uns, euch, or sie. The pronoun answers whom or what the action affects.", [["Kannst du mich hören?", "Can you hear me?"], ["Ich sehe ihn jeden Morgen.", "I see him every morning."], ["Die Lehrerin fragt uns.", "The teacher asks us."]], ["Using ich or du as an object.", "Choosing the pronoun from the subject instead of the object."], [["Complete: Ich liebe meine Eltern. Ich besuche ___ oft.", "sie", "The plural object meine Eltern becomes sie."], ["Translate: She calls me.", "Sie ruft mich an.", "The accusative form of ich is mich."], ["Correct: Kannst du ich verstehen?", "Kannst du mich verstehen?", "Ich changes to mich as a direct object."]]],
  ["a1-imperative", 19, "Polite and Informal Commands", "Use the imperative for instructions and requests. Formal Sie uses the infinitive plus Sie; du often uses the verb stem; ihr uses the normal ihr verb form without the pronoun.", [["Öffnen Sie bitte das Fenster.", "Please open the window."], ["Komm bitte pünktlich!", "Please come on time!"], ["Wartet vor dem Eingang!", "Wait in front of the entrance!"]], ["Forgetting Sie in a formal command.", "Keeping du or ihr in the informal imperative."], [["Form a polite command: warten", "Warten Sie bitte.", "The formal imperative uses the infinitive plus Sie."], ["Translate informally to one person: Come here!", "Komm hierher!", "The du imperative of kommen is komm."], ["Correct: Ihr macht bitte die Tür zu!", "Macht bitte die Tür zu!", "Remove ihr in the ihr imperative."]]],
  ["a1-place-direction", 20, "Wo, Wohin, and Woher", "Wo asks about a location, wohin about a destination, and woher about an origin. Common answers use in or bei for location, nach or in for destination, and aus or von for origin.", [["Wo bist du? Ich bin im Büro.", "Where are you? I am in the office."], ["Wohin fährst du? Ich fahre nach Berlin.", "Where are you going? I am going to Berlin."], ["Woher kommst du? Ich komme aus der Türkei.", "Where do you come from? I come from Turkey."]], ["Answering wohin with a fixed location.", "Using nach before countries with an article."], [["Choose: ___ gehst du? In die Küche.", "Wohin", "In die Küche names a destination."], ["Translate: Where does she come from?", "Woher kommt sie?", "Woher asks about origin."], ["Complete: Wo ist er? Er ist ___ Bahnhof.", "am Bahnhof", "Am Bahnhof describes a location."]]],
  ["a1-formal-address", 21, "Du, Ihr, and Formal Sie", "Use du for one familiar person, ihr for several familiar people, and capitalized Sie for one or more people in formal situations. Formal Sie uses the same verb form as sie in the plural.", [["Wie heißt du?", "What is your name? (informal singular)"], ["Woher kommt ihr?", "Where do you all come from? (informal)"], ["Haben Sie einen Termin?", "Do you have an appointment? (formal)"]], ["Writing formal Sie with a lowercase letter.", "Using a du verb ending with formal Sie."], [["Change to formal: Hast du Zeit?", "Haben Sie Zeit?", "Formal Sie uses the plural verb form haben."], ["Complete: Woher ___ ihr? (kommen)", "kommt", "Ihr takes the ending -t."], ["Correct: Sie hast eine Frage.", "Sie haben eine Frage.", "Formal Sie uses haben, not hast."]]],
  ["a1-dative-pronouns", 22, "Dative Personal Pronouns", "Use mir, dir, ihm, ihr, uns, euch, ihnen, and Ihnen for a recipient or after verbs such as helfen. The pronoun answers to whom or for whom.", [["Kannst du mir helfen?", "Can you help me?"], ["Ich gebe ihm den Schlüssel.", "I give him the key."], ["Die Lehrerin erklärt uns die Aufgabe.", "The teacher explains the task to us."]], ["Using mich where helfen requires mir.", "Confusing ihr for to her with ihr for you all."], [["Complete: Ich antworte ___. (du)", "dir", "The dative form of du is dir."], ["Translate: She helps us.", "Sie hilft uns.", "Uns is both the accusative and dative form of wir."], ["Correct: Kannst du mich helfen?", "Kannst du mir helfen?", "Helfen requires the dative, so mich changes to mir."]]],
  ["a1-comparative-basics", 23, "Simple Comparisons", "Add -er to many adjectives and use als to compare unequal things. Use so...wie when two things are equal. Learn common irregular forms such as gut-besser and gern-lieber.", [["Der Zug ist schneller als der Bus.", "The train is faster than the bus."], ["Meine Wohnung ist so groß wie deine.", "My apartment is as big as yours."], ["Ich trinke lieber Tee als Kaffee.", "I prefer drinking tea to coffee."]], ["Using wie after a comparative with -er.", "Saying guter instead of the irregular form besser."], [["Complete: Das Fahrrad ist ___ als das Auto. (langsam)", "langsamer", "Most comparatives add -er."], ["Translate: This book is as good as that one.", "Dieses Buch ist so gut wie das andere.", "Equal comparisons use so...wie."], ["Correct: Heute ist es mehr warm als gestern.", "Heute ist es wärmer als gestern.", "Warm forms the comparative wärmer."]]],
  ["a1-preposition-contractions", 24, "Am, Im, Zum, and Zur", "Frequent prepositions combine with definite articles: an dem becomes am, in dem becomes im, zu dem becomes zum, and zu der becomes zur. Beim and vom work the same way with bei and von.", [["Wir treffen uns am Bahnhof.", "We meet at the station."], ["Im Sommer fahre ich ans Meer.", "In summer I travel to the sea."], ["Ich gehe zur Apotheke.", "I am going to the pharmacy."]], ["Using zum before a feminine noun.", "Separating common contractions in everyday phrases."], [["Combine: in + dem Park", "im Park", "In dem commonly contracts to im."], ["Complete: Ich fahre ___ Arzt. (zu + dem)", "zum Arzt", "Zu dem contracts to zum."], ["Correct: Wir sind zu der Bahnhof.", "Wir sind am Bahnhof.", "A fixed location at the station is expressed with am Bahnhof."]]],
  ["a1-past-sein-haben", 25, "War and Hatte", "Use war and hatte to talk simply about past states and possession. The plural forms are waren and hatten; these forms are very common in everyday spoken German.", [["Gestern war ich krank.", "Yesterday I was ill."], ["Wir hatten am Montag einen Termin.", "We had an appointment on Monday."], ["Früher waren die Geschäfte kleiner.", "In the past the shops were smaller."]], ["Saying ich bin gewesen for every past state.", "Using war when the meaning is possession."], [["Complete: Letzte Woche ___ ich in Berlin. (sein)", "war", "The simple past of sein for ich is war."], ["Translate: We had no time.", "Wir hatten keine Zeit.", "Wir uses hatten for past possession."], ["Correct: Gestern hatte das Wetter kalt.", "Gestern war das Wetter kalt.", "A state with an adjective uses sein, so the past form is war."]]]
];

const a2 = [
  ["a2-perfect", 1, "Perfect Tense in Conversation", "Use haben or sein plus a past participle to talk about completed past events. Movement and change-of-state verbs often use sein.", [["Ich habe gestern gearbeitet.", "I worked yesterday."], ["Wir sind nach Köln gefahren.", "We traveled to Cologne."]], ["Using haben with every movement verb.", "Putting the participle in the middle of a main clause."], [["Complete: Ich ___ viel gelernt.", "habe", "Lernen forms the perfect with haben."], ["Translate: We arrived late.", "Wir sind spät angekommen.", "Ankommen uses sein and the separable participle angekommen."], ["Correct: Ich bin Kaffee getrunken.", "Ich habe Kaffee getrunken.", "Trinken uses haben."]]],
  ["a2-dative", 2, "Dative Case", "Use the dative for indirect objects and after fixed dative prepositions. Articles become dem, der, dem, and den plus -n where possible in the plural.", [["Ich helfe dem Mann.", "I help the man."], ["Sie gibt der Frau das Formular.", "She gives the woman the form."]], ["Using den without adding -n to a plural noun.", "Changing the direct object instead of the recipient."], [["Fill in: Ich antworte ___ Lehrerin.", "der Lehrerin", "Antworten takes a dative object."], ["Translate: He helps the child.", "Er hilft dem Kind.", "Kind is neuter, so use dem."], ["Complete: mit ___ Freunden", "mit den Freunden", "Mit always takes dative."]]],
  ["a2-two-way-prepositions", 3, "Two-Way Prepositions", "With an, auf, hinter, in, neben, über, unter, vor, and zwischen, use accusative for destination and dative for location.", [["Ich gehe in die Küche.", "I go into the kitchen."], ["Ich bin in der Küche.", "I am in the kitchen."]], ["Choosing case from the verb alone.", "Treating every in phrase as dative."], [["Complete: Das Buch liegt auf ___ Tisch.", "dem Tisch", "A location takes dative."], ["Translate: I put the book on the table.", "Ich lege das Buch auf den Tisch.", "A destination takes accusative."], ["Choose: Wir gehen in der/die Stadt.", "Wir gehen in die Stadt.", "Going toward a destination takes accusative."]]],
  ["a2-adjective-endings", 4, "Adjective Endings after Articles", "German adjectives take endings that signal gender, case, and number. After a definite article, common nominative endings are -e and plural -en.", [["Das ist ein guter Plan.", "That is a good plan."], ["Ich sehe die neue Wohnung.", "I see the new apartment."]], ["Leaving attributive adjectives without an ending.", "Adding endings to predicative adjectives after sein."], [["Complete: ein schön__ Tag", "ein schöner Tag", "Masculine nominative after ein takes -er."], ["Translate: the new apartment", "die neue Wohnung", "Feminine nominative after die takes -e."], ["Correct: Das Wetter ist kaltes.", "Das Wetter ist kalt.", "Predicative adjectives have no ending."]]],
  ["a2-comparative", 5, "Comparative and Superlative", "Form most comparatives with -er and use als for unequal comparisons. The superlative commonly uses am plus -sten.", [["Berlin ist größer als Bonn.", "Berlin is bigger than Bonn."], ["Heute ist es am kältesten.", "Today it is coldest."]], ["Using wie after a comparative.", "Forgetting irregular forms such as besser."], [["Complete: Mein Weg ist ___ als deiner. (kurz)", "kürzer", "Kurz takes an umlaut in the comparative."], ["Translate: This is better.", "Das ist besser.", "Gut has the irregular comparative besser."], ["Complete: am ___ (schnell)", "am schnellsten", "The adverbial superlative uses am plus -sten."]]],
  ["a2-reflexive", 6, "Reflexive Verbs", "Reflexive verbs use a pronoun that refers back to the subject: mich, dich, sich, uns, euch, sich.", [["Ich interessiere mich für Musik.", "I am interested in music."], ["Wir treffen uns um acht.", "We meet at eight."]], ["Omitting the reflexive pronoun.", "Using mich with every subject."], [["Complete: Du erinnerst ___ an den Termin.", "dich", "Du takes dich."], ["Translate: We are registering.", "Wir melden uns an.", "Wir takes uns and anmelden separates."], ["Correct: Sie freut mich auf den Urlaub.", "Sie freut sich auf den Urlaub.", "The pronoun must match sie."]]],
  ["a2-modal-past", 7, "Modal Verbs in the Past", "The simple past forms of modal verbs are common: konnte, musste, durfte, sollte, wollte, and mochte.", [["Ich musste lange warten.", "I had to wait a long time."], ["Wir konnten nicht kommen.", "We could not come."]], ["Adding an umlaut to konnte or musste.", "Using a past infinitive after the modal."], [["Complete: Gestern ___ ich arbeiten. (müssen)", "musste", "Müssen becomes musste in simple past."], ["Translate: We could help.", "Wir konnten helfen.", "Konnten agrees with wir."], ["Correct: Ich musste gearbeitet.", "Ich musste arbeiten.", "A modal takes an infinitive at the end."]]],
  ["a2-relative-basic", 8, "Basic Relative Clauses", "Relative clauses add information about a noun. The relative pronoun matches the noun's gender and its case inside the clause; the verb goes last.", [["Das ist der Mann, der hier arbeitet.", "That is the man who works here."], ["Ich mag das Buch, das du liest.", "I like the book that you are reading."]], ["Keeping the verb in second position.", "Choosing the pronoun only from the nearest word."], [["Complete: Die Frau, ___ dort steht, ist Ärztin.", "die", "Frau is feminine and subject of the relative clause."], ["Translate: the book that I am reading", "das Buch, das ich lese", "Das is the accusative neuter pronoun here."], ["Correct: Der Mann, der arbeitet hier", "Der Mann, der hier arbeitet", "The relative-clause verb goes last."]]],
  ["a2-infinitive-zu", 9, "Infinitive with Zu", "Many verbs, adjectives, and noun phrases take zu plus an infinitive. With separable verbs, zu appears between prefix and stem.", [["Ich versuche, mehr zu lernen.", "I try to learn more."], ["Es ist wichtig, pünktlich anzukommen.", "It is important to arrive on time."]], ["Using zu after modal verbs.", "Writing zu before a separable prefix."], [["Complete: Ich hoffe, bald ___ kommen.", "zu", "Hoffen takes an infinitive with zu."], ["Translate: to fill out the form", "das Formular auszufüllen", "Zu goes inside the separable verb."], ["Correct: Ich muss zu gehen.", "Ich muss gehen.", "Modal verbs take an infinitive without zu."]]],
  ["a2-indirect-questions", 10, "Indirect Questions", "Indirect questions use an introductory phrase and send the conjugated verb to the end. Yes/no questions use ob.", [["Können Sie mir sagen, wann der Kurs beginnt?", "Can you tell me when the course starts?"], ["Ich weiß nicht, ob er kommt.", "I do not know whether he is coming."]], ["Keeping question word order after the comma.", "Using wenn instead of ob for whether."], [["Complete: Wissen Sie, wo er ___?", "wohnt", "The verb goes to the end."], ["Translate: I do not know whether it is open.", "Ich weiß nicht, ob es geöffnet ist.", "Use ob for an embedded yes/no question."], ["Correct: Können Sie sagen, wann beginnt der Zug?", "Können Sie sagen, wann der Zug beginnt?", "After wann, place der Zug before the final verb beginnt."]]],
  ["a2-preterite", 11, "Simple Past of Sein and Haben", "In speech and writing, war and hatte are more natural than the perfect forms of sein and haben.", [["Gestern war ich krank.", "Yesterday I was ill."], ["Wir hatten keine Zeit.", "We had no time."]], ["Saying ich habe gewesen.", "Using hatte for a state expressed with sein."], [["Complete: Früher ___ ich mehr Zeit.", "hatte", "Having time uses hatte."], ["Translate: The office was closed.", "Das Büro war geschlossen.", "War is the simple past of sein."], ["Correct: Wir waren ein Auto.", "Wir hatten ein Auto.", "Possession uses haben."]]],
  ["a2-verbs-prepositions", 12, "Verbs with Prepositions", "Learn common verbs together with their fixed preposition and case, such as warten auf plus accusative and sprechen mit plus dative.", [["Ich warte auf den Bus.", "I am waiting for the bus."], ["Sie spricht mit ihrem Chef.", "She speaks with her boss."]], ["Translating the English preposition directly.", "Forgetting the case required by the preposition."], [["Complete: Ich interessiere mich ___ Musik.", "für Musik", "Sich interessieren takes für plus accusative."], ["Translate: We are waiting for the answer.", "Wir warten auf die Antwort.", "Warten takes auf plus accusative."], ["Complete: Er nimmt ___ dem Kurs teil.", "an dem Kurs", "Teilnehmen takes an plus dative."]]],
  ["a2-purpose", 13, "Purpose with Damit and Um...zu", "Use um...zu when both clauses have the same subject. Use damit when the subjects differ.", [["Ich lerne viel, um die Prüfung zu bestehen.", "I study a lot in order to pass the exam."], ["Ich spreche langsam, damit du mich verstehst.", "I speak slowly so that you understand me."]], ["Using um...zu with two different subjects.", "Putting zu before a separable prefix."], [["Complete: Ich rufe an, ___ einen Termin zu vereinbaren.", "um", "The subject is ich in both parts."], ["Translate: I write it down so that you remember it.", "Ich schreibe es auf, damit du dich daran erinnerst.", "The subjects change from ich to du, so connect the purpose with damit."], ["Correct: Ich helfe dir, um du fertig wirst.", "Ich helfe dir, damit du fertig wirst.", "Um...zu cannot introduce du here; damit creates a full clause with its own subject."]]],
  ["a2-participle-formation", 14, "Forming Past Participles", "Regular verbs usually form ge- plus stem plus -t. Inseparable-prefix verbs and verbs ending in -ieren do not take ge-. Separable prefixes stand before ge-.", [["Wir haben die Wohnung gemietet.", "We rented the apartment."], ["Sie hat den Termin verschoben.", "She postponed the appointment."], ["Ich habe mich gut vorbereitet.", "I prepared well."]], ["Adding ge- after be-, ver-, or er-.", "Putting ge- before a separable prefix."], [["Form the participle: machen", "gemacht", "A regular verb uses ge- plus stem plus -t."], ["Form the participle: reservieren", "reserviert", "Verbs ending in -ieren do not take ge-."], ["Correct: geausfüllt", "ausgefüllt", "With separable ausfüllen, ge- stands between prefix and stem."]]],
  ["a2-causal-connectors", 15, "Reasons and Results", "Use weil for a verb-final reason clause, denn for a normal main-clause reason, and deshalb or darum in position one of a result clause followed immediately by the verb.", [["Ich bleibe zu Hause, weil ich krank bin.", "I am staying home because I am ill."], ["Ich bleibe zu Hause, denn ich bin krank.", "I am staying home because I am ill."], ["Ich bin krank, deshalb bleibe ich zu Hause.", "I am ill, so I am staying home."]], ["Using verb-final order after denn.", "Putting the subject before the verb after deshalb."], [["Complete: Der Zug fällt aus, ___ nehme ich den Bus.", "deshalb", "Deshalb introduces the result and occupies position one."], ["Translate with denn: I am calling because I have a question.", "Ich rufe an, denn ich habe eine Frage.", "Denn keeps main-clause order."], ["Correct: Darum ich komme später.", "Darum komme ich später.", "The conjugated verb follows darum directly."]]],
  ["a2-object-pronouns", 16, "Dative and Accusative Pronouns", "Use mir, dir, ihm, ihr, uns, euch, and ihnen for recipients and mich, dich, ihn, sie, es, uns, euch, and sie for direct objects. When both objects are pronouns, accusative usually comes first.", [["Kannst du mir den Weg erklären?", "Can you explain the way to me?"], ["Ich gebe es ihm morgen.", "I will give it to him tomorrow."], ["Die Ärztin empfiehlt ihr das Medikament.", "The doctor recommends the medicine to her."]], ["Using mich where a recipient needs mir.", "Putting two pronouns in the same order as two nouns."], [["Complete: Kannst du ___ helfen? (ich)", "mir", "Helfen selects the dative; the dative object form of ich is mir."], ["Replace both objects: Ich gebe dem Mann das Formular.", "Ich gebe es ihm.", "With two pronouns, accusative es normally precedes dative ihm."], ["Correct: Sie erklärt mich die Aufgabe.", "Sie erklärt mir die Aufgabe.", "The person receiving an explanation is dative."]]],
  ["a2-indefinite-pronouns", 17, "Man, Jemand, and Niemand", "Use man for people in general, jemand for an unspecified person, niemand for no person, etwas for something, and nichts for nothing.", [["In Deutschland trennt man den Müll.", "In Germany people separate waste."], ["Hat jemand meine Tasche gesehen?", "Has anyone seen my bag?"], ["Heute habe ich nichts geplant.", "I have planned nothing today."]], ["Conjugating man like plural people.", "Using nicht etwas instead of nichts."], [["Complete: Hier darf ___ nicht rauchen.", "man", "Man expresses a general rule and takes a singular verb."], ["Translate: Nobody answered.", "Niemand hat geantwortet.", "Niemand refers to no person."], ["Choose: Ich möchte nichts/nicht etwas trinken.", "Ich möchte nichts trinken.", "Nichts is the standard negative pronoun."]]],
  ["a2-temporal-clauses", 18, "Als, Wenn, Bevor, and Nachdem", "Use als for one completed time in the past, wenn for repeated events or present and future conditions, bevor for an earlier action, and nachdem for a completed prior action.", [["Als ich nach Deutschland kam, kannte ich niemanden.", "When I came to Germany, I knew nobody."], ["Wenn ich Zeit habe, gehe ich spazieren.", "When I have time, I go for a walk."], ["Bevor ich gehe, rufe ich dich an.", "Before I leave, I call you."]], ["Using als for a repeated routine.", "Keeping the conjugated verb in the middle of the time clause."], [["Complete: ___ ich ein Kind war, wohnte ich auf dem Land.", "Als", "A single past period uses als."], ["Translate: After we ate, we went for a walk.", "Nachdem wir gegessen hatten, gingen wir spazieren.", "Nachdem marks the earlier completed action."], ["Correct: Wenn ich habe Zeit, besuche ich dich.", "Wenn ich Zeit habe, besuche ich dich.", "The verb goes to the end of the wenn clause."]]],
  ["a2-pronominal-adverbs", 19, "Da- and Wo- Compounds", "For things and ideas, combine da- or wo- with a preposition: darauf, darüber, womit. Continue to use a preposition plus a personal pronoun for people.", [["Ich warte auf den Bescheid. Ich warte darauf.", "I am waiting for the decision. I am waiting for it."], ["Worüber sprecht ihr?", "What are you talking about?"], ["Mit wem arbeitest du?", "Who are you working with?"]], ["Using worüber for a person.", "Separating da and the preposition."], [["Replace the object: Ich denke an den Termin.", "Ich denke daran.", "Daran replaces an plus a thing."], ["Ask about a thing: Auf was wartest du?", "Worauf wartest du?", "Worauf is the standard question form for things."], ["Complete for a person: ___ wem sprichst du?", "Mit", "People use the preposition plus wem, not womit."]]],
  ["a2-time-manner-place", 20, "Time, Manner, and Place", "In a neutral German sentence, details commonly appear in the order time, reason, manner, and place. This TeKaMoLo guide is a useful default, although context can move one element into position one for emphasis.", [["Ich fahre morgen mit dem Bus zur Arbeit.", "I am traveling to work by bus tomorrow."], ["Wir lernen am Abend wegen der Prüfung gemeinsam in der Bibliothek.", "We study together in the library in the evening because of the exam."], ["Am Samstag gehe ich zu Fuß in die Stadt.", "On Saturday I walk into town."]], ["Putting the place before every time expression.", "Treating TeKaMoLo as an absolute rule instead of a neutral default."], [["Order neutrally: mit dem Zug / morgen / nach Köln / ich fahre", "Ich fahre morgen mit dem Zug nach Köln.", "Time normally comes before manner and place."], ["Translate: We work together in the office on Monday.", "Wir arbeiten am Montag gemeinsam im Büro.", "The neutral order is time, manner, place."], ["Correct neutrally: Ich lerne in der Bibliothek heute ruhig.", "Ich lerne heute ruhig in der Bibliothek.", "Time normally precedes manner and place."]]],
  ["a2-double-object-order", 21, "Ordering Two Objects", "With two nouns, the dative recipient usually comes before the accusative thing. A pronoun normally comes before a noun; when both are pronouns, the accusative pronoun usually comes before the dative pronoun.", [["Ich gebe dem Kunden das Formular.", "I give the customer the form."], ["Ich gebe ihm das Formular.", "I give him the form."], ["Ich gebe es ihm.", "I give it to him."]], ["Always putting dative before accusative when both are pronouns.", "Leaving an object pronoun after a full noun phrase."], [["Replace both objects: Ich schicke der Kollegin die E-Mail.", "Ich schicke sie ihr.", "With two pronouns, accusative sie normally precedes dative ihr."], ["Complete: Die Ärztin erklärt ___ die Behandlung. (ich)", "mir", "A dative pronoun comes before the noun object."], ["Correct: Ich zeige den Ausweis ihm.", "Ich zeige ihm den Ausweis.", "The pronoun ihm normally comes before the noun object."]]],
  ["a2-reflexive-dative", 22, "Reflexive Dative", "Use a dative reflexive pronoun when the sentence already has a direct accusative object, especially with body care and personal belongings: mir, dir, sich, uns, euch, sich.", [["Ich wasche mir die Hände.", "I wash my hands."], ["Du putzt dir die Zähne.", "You brush your teeth."], ["Wir ziehen uns die Jacken an.", "We put on our jackets."]], ["Using mich even when another accusative object is present.", "Adding a possessive article where German often uses a definite article."], [["Complete: Ich kämme ___ die Haare.", "mir", "Die Haare is the accusative object, so the reflexive pronoun is dative."], ["Translate: She washes her face.", "Sie wäscht sich das Gesicht.", "The body part is accusative and sich is dative here."], ["Correct: Du wäschst dich die Hände.", "Du wäschst dir die Hände.", "With die Hände as the direct object, use dative dir."]]],
  ["a2-n-declension-basic", 23, "Weak Masculine Nouns", "Many masculine nouns for people add -n or -en in accusative, dative, and genitive singular. The nominative singular stays unchanged: der Kunde, but den Kunden and mit dem Kunden.", [["Der Kollege wartet draußen.", "The colleague is waiting outside."], ["Ich rufe den Kollegen an.", "I call the colleague."], ["Wir sprechen mit dem Kunden.", "We speak with the customer."]], ["Adding -n in the nominative singular.", "Leaving Kunde or Kollege unchanged after den or dem."], [["Complete: Ich frage den Kund__.", "Kunden", "Kunde is a weak masculine noun and adds -n outside nominative."], ["Translate: with the colleague", "mit dem Kollegen", "Kollege adds -n in the dative."], ["Correct: Der Studenten lernt Deutsch.", "Der Student lernt Deutsch.", "Nominative singular has no weak-noun ending."]]],
  ["a2-werden-changes", 24, "Changes with Werden", "Use werden plus a noun or adjective to express becoming or a change of state. Unlike the passive, there is no past participle; the new role or quality follows werden directly.", [["Es wird am Abend kalt.", "It becomes cold in the evening."], ["Meine Tochter wird Ärztin.", "My daughter is becoming a doctor."], ["Die Situation wird langsam besser.", "The situation is slowly getting better."]], ["Adding sein after werden.", "Confusing a change with the passive structure werden plus participle."], [["Complete: Im Herbst ___ es früher dunkel.", "wird", "Werden plus an adjective expresses a change of state."], ["Translate: He is becoming a teacher.", "Er wird Lehrer.", "A profession follows werden without an article."], ["Correct: Das Wetter wird sein warm.", "Das Wetter wird warm.", "The adjective follows werden directly."]]]
];

const b1 = [
  ["b1-past-narrative", 1, "Narrating in the Past", "Combine perfect tense for spoken events with common simple-past forms such as war, hatte, and modal verbs. Use time markers to make the sequence clear.", [["Zuerst habe ich angerufen, dann bin ich hingefahren.", "First I called, then I went there."], ["Früher hatte ich wenig Zeit.", "I used to have little time."]], ["Switching tenses without a reason.", "Forgetting sein with movement verbs."], [["Translate: First we booked, then we traveled.", "Zuerst haben wir gebucht, dann sind wir gereist.", "Reisen uses sein in the perfect."], ["Complete: Damals ___ ich in Köln. (sein)", "war", "Use war for a past state."], ["Correct: Ich habe nach Hause gegangen.", "Ich bin nach Hause gegangen.", "Gehen uses sein."]]],
  ["b1-relative", 2, "Relative Clauses in All Cases", "Choose a relative pronoun by the antecedent's gender and the pronoun's role inside the relative clause. Prepositions stand before the pronoun.", [["Das ist die Kollegin, mit der ich arbeite.", "That is the colleague with whom I work."], ["Der Mann, dessen Auto kaputt ist, wartet.", "The man whose car is broken is waiting."]], ["Choosing case from the main clause.", "Leaving the preposition at the end."], [["Complete: Das ist der Kurs, an ___ ich teilnehme.", "dem", "Teilnehmen an takes dative."], ["Translate: the woman whose son studies here", "die Frau, deren Sohn hier studiert", "Deren expresses possession for a feminine antecedent."], ["Correct: Die Firma, ich arbeite bei der", "Die Firma, bei der ich arbeite", "Put the preposition before the relative pronoun."]]],
  ["b1-passive", 3, "Present and Past Passive", "Form the process passive with werden plus past participle. Use wurde plus participle for simple past and ist plus participle plus worden for perfect.", [["Der Antrag wird geprüft.", "The application is being checked."], ["Die Straße wurde gesperrt.", "The street was closed."], ["Das Formular ist ausgefüllt worden.", "The form has been filled out."]], ["Using sein when describing an action in progress.", "Using geworden instead of worden in passive perfect."], [["Complete: Die E-Mail ___ heute geschickt.", "wird", "Present passive uses wird plus participle."], ["Translate: The meeting was canceled.", "Die Besprechung wurde abgesagt.", "Past passive uses wurde."], ["Correct: Der Antrag ist geprüft geworden.", "Der Antrag ist geprüft worden.", "Passive perfect uses worden."]]],
  ["b1-genitive", 4, "Genitive and Formal Possession", "The genitive expresses possession and follows several formal prepositions. Masculine and neuter nouns often add -s or -es.", [["Das ist das Auto meines Bruders.", "That is my brother's car."], ["Wegen des Wetters bleiben wir zu Hause.", "Because of the weather we are staying home."]], ["Using a nominative article after wegen in formal writing.", "Forgetting the noun ending in masculine and neuter forms."], [["Complete: wegen ___ Problems", "wegen des Problems", "Problem is neuter and takes des plus -s."], ["Translate: my friend's apartment", "die Wohnung meines Freundes", "Masculine Freund takes meines and -es."], ["Complete: trotz ___ Verspätung", "trotz der Verspätung", "Feminine genitive uses der."]]],
  ["b1-adjective-endings", 5, "Adjective Endings without Articles", "Without an article, the adjective carries the case and gender signal itself. Learn strong endings in frequent phrases.", [["Frischer Kaffee ist beliebt.", "Fresh coffee is popular."], ["Mit öffentlichen Verkehrsmitteln fahre ich günstiger.", "I travel more cheaply by public transport."]], ["Using weak -en everywhere.", "Forgetting that plural dative nouns often add -n."], [["Complete: frisch__ Gemüse", "frisches Gemüse", "Neuter nominative takes -es without an article."], ["Translate: with good friends", "mit guten Freunden", "Dative plural takes -en."], ["Complete: wegen stark__ Regens", "wegen starken Regens", "Genitive masculine uses -en here."]]],
  ["b1-n-declension", 6, "N-Declension Masculine Nouns", "Many masculine nouns for people and a few other nouns add -n or -en in every case except nominative singular.", [["Ich spreche mit dem Kollegen.", "I speak with the colleague."], ["Wir fragen den Kunden.", "We ask the customer."]], ["Leaving Kollege unchanged outside nominative.", "Adding the ending in nominative singular."], [["Complete: Ich sehe den Student__.", "Studenten", "Student belongs to n-declension."], ["Translate: with the customer", "mit dem Kunden", "Kunde becomes Kunden in dative."], ["Correct: Der Kollegen kommt.", "Der Kollege kommt.", "Nominative singular has no added -n."]]],
  ["b1-participles-adjectives", 7, "Participles as Adjectives", "Present participles describe an ongoing quality; past participles often describe a completed result. Both take normal adjective endings.", [["die wartenden Fahrgäste", "the waiting passengers"], ["das ausgefüllte Formular", "the completed form"]], ["Forgetting adjective endings.", "Confusing an active present meaning with a completed result."], [["Complete: die ___ Tür (schließen)", "die geschlossene Tür", "The past participle describes the closed result."], ["Translate: the sleeping child", "das schlafende Kind", "The present participle adds -d and an adjective ending."], ["Complete: ein gut ___ Bericht (schreiben)", "ein gut geschriebener Bericht", "The participle takes the masculine adjective ending." ]]],
  ["b1-nominalization", 8, "Nominalization", "Infinitives and adjectives can become nouns. Nominalized forms are capitalized and usually neuter when formed from verbs.", [["Das Lesen macht mir Spaß.", "Reading is fun for me."], ["Wir wünschen Ihnen alles Gute.", "We wish you all the best."]], ["Writing nominalized verbs with lowercase letters.", "Adding a plural to every nominalized infinitive."], [["Correct capitalization: beim essen", "beim Essen", "The verb is nominalized after beim."], ["Translate: Learning is important.", "Das Lernen ist wichtig.", "A nominalized infinitive is neuter and capitalized."], ["Complete: etwas ___ (neu)", "etwas Neues", "A nominalized adjective after etwas takes -es."]]],
  ["b1-connectors", 9, "Paired and Contrast Connectors", "Organize arguments with einerseits...andererseits, zwar...aber, sowohl...als auch, weder...noch, and nicht nur...sondern auch.", [["Einerseits ist die Wohnung günstig, andererseits ist sie klein.", "On one hand the apartment is affordable; on the other it is small."], ["Der Kurs ist nicht nur hilfreich, sondern auch flexibel.", "The course is not only helpful but also flexible."]], ["Using sondern without a preceding negation.", "Breaking parallel structure after paired connectors."], [["Complete: ___ ist der Weg lang, aber er ist schön.", "Zwar", "Zwar pairs naturally with aber."], ["Translate: neither expensive nor impractical", "weder teuer noch unpraktisch", "Weder pairs with noch."], ["Complete: sowohl online ___ vor Ort", "als auch", "Sowohl pairs with als auch."]]],
  ["b1-indirect-speech", 10, "Reporting Speech", "Report information with dass clauses or, in formal contexts, Konjunktiv I. Everyday B1 communication often uses a reporting verb plus dass.", [["Er sagt, dass er später kommt.", "He says that he will come later."], ["Die Zeitung berichtet, der Kurs sei erfolgreich.", "The newspaper reports that the course is successful."]], ["Keeping main-clause word order after dass.", "Presenting reported information as your own fact."], [["Translate: She says that she is ill.", "Sie sagt, dass sie krank ist.", "The verb goes last in the dass clause."], ["Complete formally: Er sagt, er ___ müde.", "sei", "Sei is Konjunktiv I of sein."], ["Correct: Er meint, dass ist es richtig.", "Er meint, dass es richtig ist.", "The reported dass clause ends with ist: dass es richtig ist."]]],
  ["b1-future", 11, "Future and Assumptions with Werden", "Use werden plus infinitive for explicit future intentions and werden plus wohl for assumptions. Present tense with a time word is often enough for plans.", [["Ich werde mich morgen melden.", "I will contact you tomorrow."], ["Er wird wohl noch arbeiten.", "He is probably still working."]], ["Using werden when a simple present plan sounds more natural.", "Putting the infinitive before objects."], [["Complete: Wir ___ das Problem lösen.", "werden", "Wir takes werden."], ["Translate: She is probably at home.", "Sie wird wohl zu Hause sein.", "Werden plus wohl expresses an assumption."], ["Correct: Ich werde gehen morgen.", "Ich werde morgen gehen.", "The infinitive goes at the end."]]],
  ["b1-concessive", 12, "Concession with Obwohl and Trotzdem", "Use obwohl to introduce a subordinate clause with the verb at the end. Trotzdem begins a main clause and is followed by the conjugated verb.", [["Obwohl es regnet, fahren wir Rad.", "Although it is raining, we ride our bikes."], ["Es regnet. Trotzdem fahren wir Rad.", "It is raining. Nevertheless, we ride our bikes."]], ["Using main-clause order after obwohl.", "Putting the subject before the verb after trotzdem."], [["Complete: ___ ich müde bin, lerne ich.", "Obwohl", "The subordinate clause gives a concession."], ["Translate: It is expensive; nevertheless I buy it.", "Es ist teuer. Trotzdem kaufe ich es.", "Trotzdem occupies position one, so the verb follows."], ["Correct: Trotzdem ich bin krank, arbeite ich.", "Obwohl ich krank bin, arbeite ich.", "Use obwohl to introduce a clause."]]],
  ["b1-alternatives", 13, "Alternative Passive Forms", "Use sein plus zu plus infinitive or sich lassen plus infinitive to express possibility or necessity without naming an actor.", [["Das Problem lässt sich lösen.", "The problem can be solved."], ["Der Antrag ist bis Freitag einzureichen.", "The application must be submitted by Friday."]], ["Treating every sein plus zu form as simple ability.", "Conjugating the infinitive after lässt sich."], [["Translate: The text can be understood easily.", "Der Text lässt sich leicht verstehen.", "Sich lassen expresses possibility."], ["Complete: Das Formular ist auszufüll__.", "auszufüllen", "Zu appears inside the separable infinitive."], ["Correct: Das lässt sich gelöst.", "Das lässt sich lösen.", "Lassen takes an infinitive."]]],
  ["b1-plusquamperfekt", 14, "Past Perfect in Narratives", "Use hatte or war plus past participle for an event that was already complete before another past event. Movement and change-of-state verbs use war.", [["Nachdem ich den Antrag ausgefüllt hatte, gab ich ihn ab.", "After I had completed the application, I handed it in."], ["Der Zug war schon abgefahren, als wir ankamen.", "The train had already left when we arrived."], ["Sie hatte den Termin vergessen und rief später an.", "She had forgotten the appointment and called later."]], ["Using the present perfect helper habe in a past-perfect clause.", "Using hatte with every movement verb."], [["Complete: Er ___ schon gegangen. (sein)", "war", "Gehen uses sein, so the past-perfect helper is war."], ["Translate: I had already paid.", "Ich hatte schon bezahlt.", "The past perfect uses hatte plus participle."], ["Correct: Nachdem ich gegessen habe, ging ich los.", "Nachdem ich gegessen hatte, ging ich los.", "The earlier action in this past narrative uses the past perfect."]]],
  ["b1-temporal-connectors", 15, "Precise Time Relationships", "Use nachdem for a completed prior event, bevor or ehe for an event that follows, während for simultaneous actions, and seitdem for a state continuing from the past.", [["Nachdem die Sitzung beendet war, schrieb ich das Protokoll.", "After the meeting had ended, I wrote the minutes."], ["Während sie telefonierte, bereitete ich die Unterlagen vor.", "While she was on the phone, I prepared the documents."], ["Seitdem ich den Kurs besuche, spreche ich sicherer.", "Since I started attending the course, I speak more confidently."]], ["Using the same time relationship for nachdem and bevor.", "Forgetting verb-final order in the temporal clause."], [["Complete: ___ ich den Vertrag unterschreibe, lese ich ihn genau.", "Bevor", "Reading occurs before signing."], ["Translate: While I work, I listen to the radio.", "Während ich arbeite, höre ich Radio.", "Während marks simultaneous actions."], ["Correct: Seitdem ich besuche den Kurs, schreibe ich besser.", "Seitdem ich den Kurs besuche, schreibe ich besser.", "The verb goes to the end of the seitdem clause."]]],
  ["b1-conditionals", 16, "Real and Hypothetical Conditions", "Use wenn, falls, or sofern for realistic conditions. Use Konjunktiv II in both clauses for imagined or unlikely conditions.", [["Falls Sie Fragen haben, melden Sie sich bitte.", "If you have questions, please contact us."], ["Sofern alle Unterlagen vorliegen, wird der Antrag bearbeitet.", "Provided all documents are available, the application will be processed."], ["Wenn ich mehr Zeit hätte, würde ich öfter lesen.", "If I had more time, I would read more often."]], ["Using würde in the condition but present tense in the imagined result.", "Treating falls as a certainty rather than a condition."], [["Complete politely: ___ Sie verhindert sind, sagen Sie bitte ab.", "Falls", "Falls introduces a possible condition."], ["Translate: If I knew the answer, I would tell you.", "Wenn ich die Antwort wüsste, würde ich sie dir sagen.", "Both clauses describe an unreal situation."], ["Correct: Wenn ich hätte mehr Geld, würde ich reisen.", "Wenn ich mehr Geld hätte, würde ich reisen.", "The conjugated verb goes to the end of the wenn clause."]]],
  ["b1-extended-infinitives", 17, "Ohne...zu and Statt...zu", "Use ohne...zu for an action that does not happen and statt...zu for an alternative action. The infinitive group normally shares its subject with the main clause.", [["Er ging, ohne sich zu verabschieden.", "He left without saying goodbye."], ["Statt lange zu warten, rief sie direkt an.", "Instead of waiting a long time, she called directly."], ["Sie spart Geld, um eine Weiterbildung zu machen.", "She saves money in order to take continuing education."]], ["Using these infinitive groups with a different hidden subject.", "Putting zu before a separable prefix."], [["Complete: Sie antwortete, ohne lange ___. (überlegen)", "zu überlegen", "Ohne introduces a zu-infinitive group."], ["Translate: Instead of complaining, he proposes a solution.", "Statt sich zu beschweren, schlägt er eine Lösung vor.", "Statt...zu presents an alternative action with the same subject."], ["Correct: ohne zu anzurufen", "ohne anzurufen", "With anrufen, zu stands between the prefix and stem."]]],
  ["b1-collocations", 18, "Verb-Noun Collocations", "Formal German often expresses one idea through a fixed noun-verb partnership. Learn combinations such as eine Entscheidung treffen, einen Antrag stellen, and Rücksicht nehmen as complete units.", [["Die Behörde trifft nächste Woche eine Entscheidung.", "The authority will make a decision next week."], ["Wir müssen einen Antrag auf Verlängerung stellen.", "We must submit an application for an extension."], ["Bitte nehmen Sie Rücksicht auf die Nachbarn.", "Please show consideration for the neighbors."]], ["Translating the English verb literally.", "Changing the article inside a fixed expression."], [["Complete: eine Entscheidung ___", "treffen", "Eine Entscheidung treffen is a fixed collocation."], ["Translate: to submit an application", "einen Antrag stellen", "German uses stellen with Antrag."], ["Correct: Rücksicht machen", "Rücksicht nehmen", "Rücksicht pairs with nehmen."]]],
  ["b1-result-manner", 19, "Method and Result Clauses", "Use indem or dadurch, dass to explain how something happens. Use sodass or so...dass to express a result or consequence.", [["Man verbessert die Aussprache, indem man regelmäßig laut liest.", "You improve pronunciation by reading aloud regularly."], ["Die Stadt spart Energie dadurch, dass sie alte Gebäude saniert.", "The city saves energy by renovating old buildings."], ["Der Zug hatte Verspätung, sodass wir den Anschluss verpassten.", "The train was delayed, so we missed the connection."]], ["Using indem for a consequence instead of a method.", "Keeping main-clause word order after sodass."], [["Complete: Sie lernt neue Wörter, ___ sie Karteikarten benutzt.", "indem", "The second clause explains the method."], ["Translate: It was so loud that I could not sleep.", "Es war so laut, dass ich nicht schlafen konnte.", "So...dass expresses a result."], ["Correct: Es regnete, sodass wir blieben zu Hause.", "Es regnete, sodass wir zu Hause blieben.", "The verb goes to the end of the sodass clause."]]],
  ["b1-passive-modal-verbs", 20, "Passive with Modal Verbs", "Combine a modal verb with a past participle and werden to express necessity, permission, or possibility without naming the actor. The modal is conjugated and werden remains the final infinitive.", [["Der Antrag muss heute geprüft werden.", "The application must be checked today."], ["Das Problem kann schnell gelöst werden.", "The problem can be solved quickly."], ["Die Tür darf nicht geöffnet werden.", "The door must not be opened."]], ["Conjugating werden instead of the modal verb.", "Leaving werden out after the past participle."], [["Complete: Die Rechnung muss bezahlt ___.", "werden", "A modal passive ends with participle plus werden."], ["Translate: The form can be completed online.", "Das Formular kann online ausgefüllt werden.", "Kann is conjugated; ausgefüllt werden closes the clause."], ["Correct: Der Termin muss abgesagt wird.", "Der Termin muss abgesagt werden.", "After a modal verb, use the infinitive werden."]]],
  ["b1-relative-wo-was", 21, "Relative Clauses with Wo and Was", "Use wo to refer to places in everyday language and was after das, alles, nichts, or a whole preceding statement. With a specific noun and formal precision, a preposition plus relative pronoun is often better.", [["Das ist der Ort, wo wir uns treffen.", "That is the place where we meet."], ["Alles, was er sagt, ist wichtig.", "Everything he says is important."], ["Sie kam zu spät, was mich überraschte.", "She arrived late, which surprised me."]], ["Using was after an ordinary masculine, feminine, or neuter noun.", "Using wo for every noun that names a place in formal writing."], [["Complete: Nichts, ___ du sagst, ändert die Entscheidung.", "was", "Nichts is followed by the relative word was."], ["Translate: That is the city in which I studied.", "Das ist die Stadt, in der ich studiert habe.", "Formal precision uses preposition plus relative pronoun for a specific noun."], ["Correct: Der Bericht, was ich gelesen habe, war hilfreich.", "Der Bericht, den ich gelesen habe, war hilfreich.", "An ordinary masculine noun takes a matching relative pronoun, here accusative den."]]],
  ["b1-modal-particles", 22, "Modal Particles in Conversation", "Words such as doch, mal, eben, ja, and wohl add attitude and social nuance without changing the basic facts. Their meaning depends on context and sentence stress, so learn them in complete spoken phrases.", [["Komm doch mal vorbei!", "Do come by sometime!"], ["Das ist eben nicht so einfach.", "It simply is not that easy."], ["Er wird wohl noch arbeiten.", "He is probably still working."]], ["Translating every modal particle word for word.", "Using particles so often that the sentence sounds impatient or unclear."], [["Soften the request with mal: Komm bitte her.", "Komm bitte mal her.", "Mal can make a spoken request sound less abrupt."], ["Complete for a probable assumption: Sie ist ___ noch unterwegs.", "wohl", "Wohl signals that the speaker considers something probable."], ["Complete with the particle for shared knowledge: Das weißt du ___.", "doch", "Doch appeals to something the listener should already know."]]],
  ["b1-concessive-alternatives", 23, "Richer Concessive Links", "Use auch wenn for a real repeated obstacle, selbst wenn for an extreme or hypothetical obstacle, and zwar...aber to acknowledge one point before contrasting it. Trotz plus a noun compresses the same relationship.", [["Auch wenn es regnet, fahre ich mit dem Fahrrad.", "Even when it rains, I ride my bicycle."], ["Selbst wenn es teurer wäre, würde ich den Kurs wählen.", "Even if it were more expensive, I would choose the course."], ["Der Weg ist zwar lang, aber sehr schön.", "The route is long, but very beautiful."]], ["Using selbst wenn without verb-final order.", "Using zwar without a later contrast."], [["Complete: ___ wenn ich wenig Zeit habe, übe ich täglich.", "Auch", "Auch wenn presents a real obstacle that does not change the result."], ["Translate: Despite the delay, we arrived on time.", "Trotz der Verspätung kamen wir pünktlich an.", "Trotz plus a noun creates a compact concession."], ["Correct: Zwar der Kurs ist schwer, ich lerne viel.", "Der Kurs ist zwar schwer, aber ich lerne viel.", "Zwar normally prepares a contrast with aber."]]],
  ["b1-konjunktiv-past", 24, "Unreal Past Conditions", "Use hätte or wäre plus a past participle to imagine a different past. In the result clause, use hätte or wäre as well; with modal verbs, hätte plus a double infinitive is common.", [["Wenn ich früher losgefahren wäre, hätte ich den Zug erreicht.", "If I had left earlier, I would have caught the train."], ["Ich hätte den Antrag rechtzeitig abgegeben.", "I would have submitted the application on time."], ["Wir hätten länger bleiben können.", "We could have stayed longer."]], ["Using würde plus a past participle for every unreal past result.", "Putting hätte before the double infinitive in a main clause."], [["Complete: Wenn sie gelernt hätte, ___ sie bestanden.", "hätte", "An unreal past result uses hätte plus past participle."], ["Translate: If we had arrived earlier, we would have found seats.", "Wenn wir früher angekommen wären, hätten wir Plätze gefunden.", "Ankommen uses wäre; the result uses hätten plus gefunden."], ["Correct: Ich würde den Termin nicht vergessen haben.", "Ich hätte den Termin nicht vergessen.", "The standard unreal past uses hätte plus past participle."]]]
];

for (const item of a1Additional) addGrammar("A1", ...item);
for (const item of a2) addGrammar("A2", ...item);
for (const item of b1) addGrammar("B1", ...item);

function addPractice(practice, seenPrompts, prompt, answer, explanation) {
  if (seenPrompts.has(prompt)) {
    const existing = practice.find(item => item.prompt === prompt);
    if (existing) {
      existing.answer = answer;
      existing.explanation = explanation;
    }
  } else {
    practice.push({ prompt, answer, explanation });
    seenPrompts.add(prompt);
  }
}

function clozeExercise(sentence, topicTitle) {
  const tokens = sentence.split(/\s+/);
  let targetIndex = 0;
  let target = "";
  tokens.forEach((token, index) => {
    const cleaned = token.replace(/[„“.,!?;:]/g, "");
    if (cleaned.length > target.length) {
      target = cleaned;
      targetIndex = index;
    }
  });
  const promptTokens = [...tokens];
  promptTokens[targetIndex] = tokens[targetIndex].replace(target, "___");
  return { prompt: `Complete the ${topicTitle} model: ${promptTokens.join(" ")}`, answer: target };
}

function reorderExercise(sentence, topicTitle) {
  const tokens = sentence.split(/\s+/);
  const shifted = tokens.length > 3 ? [...tokens.slice(2), ...tokens.slice(0, 2)] : [...tokens].reverse();
  return `Build the ${topicTitle} sentence: ${shifted.join(" / ")}`;
}

for (const topic of grammar) {
  topic.practice = topic.practice.slice(0, 3);
  const seenPrompts = new Set(topic.practice.map(item => item.prompt));
  for (const example of topic.examples) {
    const translationExplanation = `Use the ${topic.title.toLowerCase()} model “${example.german}” for this English meaning: “${example.english}” Compare the verb position and endings with your answer.`;
    addPractice(topic.practice, seenPrompts, `Translate for ${topic.title}: ${example.english}`, example.german, translationExplanation);
    const cloze = clozeExercise(example.german, topic.title);
    const clozeExplanation = `“${cloze.answer}” restores the missing part of the ${topic.title.toLowerCase()} pattern in “${example.german}”.`;
    addPractice(topic.practice, seenPrompts, cloze.prompt, cloze.answer, clozeExplanation);
    const reorderExplanation = `Rebuild “${example.german}” by locating the conjugated verb first, then placing the remaining parts around the ${topic.title.toLowerCase()} pattern.`;
    addPractice(topic.practice, seenPrompts, reorderExercise(example.german, topic.title), example.german, reorderExplanation);
  }
}

grammar.sort((left, right) => {
  const levelOrder = { A1: 0, A2: 1, B1: 2 };
  return levelOrder[left.level] - levelOrder[right.level] || left.order - right.order;
});
fs.writeFileSync(grammarFile, JSON.stringify(grammar, null, 2) + "\n");

const counts = Object.fromEntries(["A1", "A2", "B1"].map(level => [
  level,
  JSON.parse(fs.readFileSync(path.join(root, `vocab_${level.toLowerCase()}.json`), "utf8")).length
]));
console.log(JSON.stringify({ vocabulary: counts, grammar: grammar.reduce((result, topic) => {
  result[topic.level] = (result[topic.level] || 0) + 1;
  return result;
}, {}) }, null, 2));
