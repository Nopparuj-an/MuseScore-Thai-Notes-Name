//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Thai Note Names Plugin
//
//  Original Note Names Plugin:
//  Copyright (C) 2012 Werner Schweer
//  Copyright (C) 2013 - 2021 Joachim Schmitz
//  Copyright (C) 2014 Jörn Eichler
//  Copyright (C) 2020 Johan Temmerman
//
//  Modified for Thai Note Names by Nopparuj Ananvoranich
//  Copyright (C) 2025 Nopparuj Ananvoranich
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
   version: "4.0"
   description: "This plugin names notes in Thai format."
   title: "Thai Note Names"
   categoryCode: "composing-arranging-tools"
   thumbnailName: "thai_note_names.png"

   // Small note name size is fraction of the full font size.
   property real fontSizeMini: 0.7;

   function getScaleOffset(keySignature) {
      // Map key signatures to scale offsets
      switch (keySignature) {
         case -4: return 4;  // Ab major / F minor
         case 3: return 3;   // A major / F# minor
         case -2: return 2;  // Bb major / G minor
         case 5: return 1;   // B major / G# minor
         case -7: return 1;  // Cb major / Ab minor
         case 0: return 0;   // C major / A minor
         case 7: return -1;  // C# major / A# minor
         case -5: return -1; // Db major / Bb minor
         case 2: return -2;  // D major / B minor
         case -3: return -3; // Eb major / C minor
         case 4: return -4;  // E major / C# minor
         case -1: return -5; // F major / D minor
         case 6: return -6;  // F# major / D# minor
         case -6: return -6; // Gb major / Eb minor
         case 1: return -7;  // G major / E minor
         default: return 0;  // Default to C major / A minor
      }
   }

   function nameChord (notes, text, small, scaleOffset) {
      var sep = "\n";
      var oct = "";
      var name;
      for (var i = 0; i < notes.length; i++) {
         if (!notes[i].visible)
            continue
         if (text.text)
            text.text = sep + text.text;
         if (small)
            text.fontSize *= fontSizeMini;
         if (typeof notes[i].tpc === "undefined")
            return

         var newKey = notes[i].pitch + scaleOffset;

         // if the note is too high or too low, saturate it to the same octave
         if (newKey < 48) {
            newKey = 48 + (newKey % 12);
         } else if (newKey > 83) {
            newKey = 72 + (newKey % 12);
         }
            
         switch (newKey) {
            // Thai note mapping
            // middle C is 60, low C is 48, high C is 72
            case 48: name = "ดฺ"; break;
            case 49: name = "ดฺ♯"; break;
            case 50: name = "รฺ"; break;
            case 51: name = "รฺ♯"; break;
            case 52: name = "มฺ"; break;
            case 53: name = "ฟฺ"; break;
            case 54: name = "ฟฺ♯"; break;
            case 55: name = "ซฺ"; break;
            case 56: name = "ซฺ♯"; break;
            case 57: name = "ลฺ"; break;
            case 58: name = "ลฺ♯"; break;
            case 59: name = "ทฺ"; break;

            case 60: name = "ด"; break;
            case 61: name = "ด♯"; break;
            case 62: name = "ร"; break;
            case 63: name = "ร♯"; break;
            case 64: name = "ม"; break;
            case 65: name = "ฟ"; break;
            case 66: name = "ฟ♯"; break;
            case 67: name = "ซ"; break;
            case 68: name = "ซ♯"; break;
            case 69: name = "ล"; break;
            case 70: name = "ล♯"; break;
            case 71: name = "ท"; break;

            case 72: name = "ดํ"; break;
            case 73: name = "ดํ♯"; break;
            case 74: name = "รํ"; break;
            case 75: name = "รํ♯"; break;
            case 76: name = "มํ"; break;
            case 77: name = "ฟํ"; break;
            case 78: name = "ฟํ♯"; break;
            case 79: name = "ซํ"; break;
            case 80: name = "ซํ♯"; break;
            case 81: name = "ลํ"; break;
            case 82: name = "ลํ♯"; break;
            case 83: name = "ทํ"; break;

            default: name = ""; break; // no note name
         }
         text.text = name + oct + text.text
      }
   }

   function renderGraceNoteNames (cursor, list, text, small) {
      if (list.length > 0) {     // Check for existence.
         // Now render grace note's names...
         for (var chordNum = 0; chordNum < list.length; chordNum++) {
            // iterate through all grace chords
            var chord = list[chordNum];
            // Set note text, grace notes are shown a bit smaller
            nameChord(chord.notes, text, small)
            if (text.text)
               cursor.add(text)
            // X position the note name over the grace chord
            text.offsetX = chord.posX
            switch (cursor.voice) {
               case 1: case 3: text.placement = Placement.BELOW; break;
            }

            // If we consume a STAFF_TEXT we must manufacture a new one.
            if (text.text)
               text = newElement(Element.STAFF_TEXT);    // Make another STAFF_TEXT
         }
      }
      return text
   }

   onRun: {
      curScore.startCmd()

      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1);
      if (!cursor.segment) { // no selection
         fullScore = true;
         startStaff = 0; // start with 1st staff
         endStaff  = curScore.nstaves - 1; // and end with last
      } else {
         startStaff = cursor.staffIdx;
         cursor.rewind(2);
         if (cursor.tick === 0) {
            // this happens when the selection includes
            // the last measure of the score.
            // rewind(2) goes behind the last segment (where
            // there's none) and sets tick=0
            endTick = curScore.lastSegment.tick + 1;
         } else {
            endTick = cursor.tick;
         }
         endStaff = cursor.staffIdx;
      }
      console.log(startStaff + " - " + endStaff + " - " + endTick)

      for (var staff = startStaff; staff <= endStaff; staff++) {
         for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(1); // beginning of selection
            cursor.voice    = voice;
            cursor.staffIdx = staff;

            if (fullScore)  // no selection
               cursor.rewind(0); // beginning of score
            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
               if (cursor.element && cursor.element.type === Element.CHORD) {
                  var text = newElement(Element.STAFF_TEXT);      // Make a STAFF_TEXT

                  // Get the key signature at the current segment
                  var keySignature = cursor.keySignature;
                  var scaleOffset = getScaleOffset(keySignature);

                  // First...we need to scan grace notes for existence and break them
                  // into their appropriate lists with the correct ordering of notes.
                  var leadingLifo = Array();   // List for leading grace notes
                  var trailingFifo = Array();  // List for trailing grace notes
                  var graceChords = cursor.element.graceNotes;
                  // Build separate lists of leading and trailing grace note chords.
                  if (graceChords.length > 0) {
                     for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                        var noteType = graceChords[chordNum].notes[0].noteType
                        if (noteType === NoteType.GRACE8_AFTER || noteType === NoteType.GRACE16_AFTER ||
                              noteType === NoteType.GRACE32_AFTER) {
                           trailingFifo.unshift(graceChords[chordNum])
                        } else {
                           leadingLifo.push(graceChords[chordNum])
                        }
                     }
                  }

                  // Next process the leading grace notes, should they exist...
                  text = renderGraceNoteNames(cursor, leadingLifo, text, true, scaleOffset)

                  // Now handle the note names on the main chord...
                  var notes = cursor.element.notes;
                  nameChord(notes, text, false, scaleOffset);
                  if (text.text)
                     cursor.add(text);

                  switch (cursor.voice) {
                     case 1: case 3: text.placement = Placement.BELOW; break;
                  }

                  if (text.text)
                     text = newElement(Element.STAFF_TEXT) // Make another STAFF_TEXT object

                  // Finally process trailing grace notes if they exist...
                  text = renderGraceNoteNames(cursor, trailingFifo, text, true, scaleOffset)
               } // end if CHORD
               cursor.next();
            } // end while segment
         } // end for voice
      } // end for staff

      curScore.endCmd()
      quit();
   } // end onRun
}
