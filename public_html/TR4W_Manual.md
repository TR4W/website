# TR4W User Manual — Reorganized & Expanded
**Version 4.01 | June 11, 2014**
Contributors: Larry Tyree N6TR · Doc Evans N7DR · Dmitriy Gulyaev UA4WLI
Editor: Howard Hoyt N4AF · Tod Olson K0TO

---

# PART I — GETTING STARTED

## Chapter 1 — Introduction

TR4W is a high-performance software package suitable for contests, DXpeditions, or
day-to-day operation. It is almost identical in use to TR-Log (a DOS program) but
has the advantage of running on all modern Windows platforms: XP, Vista, 7, and 8.
Like other sophisticated contest programs (N1MM, NA, CT), TR4W requires study of
alternatives and experimentation to achieve the best configuration for each operator.

### 1.1 Feature Highlights

1. Unsurpassed flexibility — tailor the program to your personal operating taste
2. Over 140 contests supported; others can be added easily
3. Capacity for more than 50,000 QSOs
4. Simple operation with intelligent ENTER key — TR4W knows what you want to do
5. CW keying via Serial Port, LPT Port, or Winkey; CW speed 1–99 WPM
6. Paddle input via LPT — touching a paddle aborts computer-generated CW
7. PTT support with programmable delay for cold-switching antenna relays
8. Winkeyer USB support
9. Automatic super check partial (SCP) and possible-call checking
10. Expanded .DTA database format: names, QTH, grid, SS check, and more
11. Band map with color-coded aging information
12. Built-in Telnet DX Cluster interface with automatic spot insertion into band map
13. Provision for responding to tail-ending stations on CW
14. Dynamic speed and weight control during stored CW message playback
15. RTTY support using the MMTTY engine
16. VHF/UHF rover station support; all amateur bands from 160 m to light
17. Beam headings and sunrise/sunset times displayed for each worked country
18. WAE QTC support for both inside and outside Europe
19. POST program for summary sheets, .DTA database maintenance, reports, and QSL labels
20. Remembers exchange information band-to-band
21. Radio interface for Elecraft, Icom, Japan Radio, Kenwood, Ten-Tec, and Yaesu
22. Networked multi-rig support (client/server TCP/IP)
23. Footswitch input via LPT port
24. Antenna band decoder output via LPT port
25. Antenna rotator control
26. Integrated SO2R two-radio support
27. On-the-fly MP3 contest recording
28. Log backup via USB drive or selected HDD folder
29. Standard CTY.DAT for country/beam heading information
30. Powerful domestic templates for easy contest additions
31. Programmable list of remaining country multipliers
32. User-programmable window and sub-window colors

### 1.2 Typographical Conventions

| Element | Convention | Example |
|---|---|---|
| Configuration Statements | ALL CAPS BOLD | **TWO RADIO MODE TRUE** |
| File Names | ALL CAPS BOLD ITALIC + extension | ***TR4W.INI*** |
| Window / Sub-Window Names | Each Word Capitalized, Bold Italic | ***Call window***, ***Exchange window*** |
| Special / Hot Keys | Described by name | Ctrl-J, Alt-D, Shift-Ctrl-2 |
| Function Keys | F1–F12 | F1 (CQ), F2 (Exchange) |

### 1.3 Getting Help

Questions and suggestions can be directed to the TR4W user reflector:
**tr4w.googlegroups.com**

---

## Chapter 2 — Installation & Initial Setup

### 2.1 System Requirements

TR4W runs on Windows XP, Vista, 7, and 8 (32-bit and 64-bit). Note that the
POST.EXE utility (used for TRMASTER.DTA customization) requires a 32-bit Windows
environment and **will not run on Windows 7 x64**.

### 2.2 Files Used by the Program

TR4W uses several key file types:

- **TR4W.INI** — master configuration; lives in the SETTINGS subfolder
- **CONTESTNAME.CFG** — per-contest configuration statements
- **TRMASTER.DTA** — callsign database (name, QTH, grid, SS check, etc.)
- **CTY.DAT** — country/prefix/beam heading data (standard format)
- **INITIAL.EX** — per-contest exchange prefill data
- **BANDMAP.BIN** — saved bandmap state (in contest directory)
- **HELLO.DAT** — country-specific greeting overrides

### 2.3 Folders Used by the Program

| Folder | Purpose |
|---|---|
| TR4W root | Executable, TRMASTER.DTA, CTY.DAT, lameenc.dll |
| SETTINGS | TR4W.INI |
| CONTESTNAME\ | Per-contest .CFG, logs, ADIF, Cabrillo, INITIAL.EX |
| DVP\ (default) | .WAV audio message files |
| DVP\LETTERSANDNUMBERS\ | Individual letter/digit .WAV files for auto-generation |
| DVP\FULLCALLSIGNS\ | Pre-recorded full callsign .WAV files |
| DVP\FULLSERIALNUMBERS\ | Pre-recorded serial number .WAV files |
| DOM\ | Domestic multiplier .DOM files |
| MP3\ (default) | MP3 contest recordings |
| COMMONMESSAGES.INI | Non-contest-specific SO2R Function Key definitions |

### 2.4 Program Installation

*(See Figures 1-1 through 1-7 in original manual for installation screenshots)*

### 2.5 Program Startup Screens

Contest selection occurs at every TR4W initialization. Two options are presented:

1. **Select an existing contest directory** — the last active configuration appears at
   the bottom for quick reload.
2. **Select a new contest** — opens the new contest dialog.

> **WARNING:** The checkboxes on the startup screen govern how your Cabrillo log is
> generated. If you are in North America, be sure to check **I AM IN NORTH AMERICA**
> or the follow-on state/province dialog will not appear and your Cabrillo will be wrong.
> CATEGORY fields filled here become your Cabrillo headers.

### 2.6 Configuring TR4W for Your Station

#### 2.6.1 Configuring the Radio

Supported manufacturers: Elecraft, Icom, Japan Radio (JRC), Kenwood, Ten-Tec, Yaesu.
COM or USB-to-Serial adapters are supported. Use **Ctrl-Alt-1** for Radio 1 setup
and **Ctrl-Alt-2** for Radio 2 setup. Winkey setup is **Ctrl-W**.

*(See Figures 1-8 through 1-11 for radio configuration dialog screenshots)*

#### 2.6.2 Configuring Station Control

Set antenna band decoders, PTT delays, and LPT port assignments via Ctrl-J
Configuration Statements.

#### 2.6.3 Configuring the Computer–Sound Interface

A hardware interface between the radio audio output and the PC sound card is
recommended to eliminate ground loops and match impedances. The UU2JJ circuit
(see Appendix B) is a proven design. In some cases a direct connection may work,
but level-matching with transformers and potentiometers is usually needed.

#### 2.6.4 Testing the Configuration Setup

Use **Alt-R** to verify proper SO2R hardware setup; the active radio display should
gray out when focus is swapped to the second radio.

---

# PART II — THE PROGRAM INTERFACE

## Chapter 3 — Main Window & Menus

### 3.1 Main Window Overview

The Main Window is the primary operating surface. Key sub-windows visible inside it:

- **Call window** — callsign entry
- **Exchange window** — received exchange entry
- **Operating Mode box** — CQ or S&P indicator
- **Possible Calls window** — SCP partial-call matches
- **User Info window** — TRMASTER.DTA display data
- **Name window** — operator name from TRMASTER
- **Band Map window** — frequency-sorted spot display
- **Function Key display** — programmed F-key captions

### 3.2 Sub-Window Colors

All sub-window foreground and background colors are user-programmable via
Configuration Statements. Default color assignments are listed in **Appendix F**.
Use Ctrl-J to locate and change any color setting at runtime.

### 3.3 Menus and Sub-Menus

#### 3.3.1 File Menu
New log, Open log, Save, Import ADIF, Export (ADIF / Cabrillo / INITIAL.EX),
Print, Exit.

#### 3.3.2 Settings Menu
Opens the Configuration Statements (Ctrl-J) dialog.

#### 3.3.3 Window Menu
Toggles sub-windows: Band Map, SCP, Function Keys, MP3 Recorder, Intercom,
Station info, Score by hour, etc.

#### 3.3.4 Alt- Menu
Alt-key shortcuts (see **Appendix C** for full list).

#### 3.3.5 Ctrl- Menu
Ctrl-key shortcuts (see **Appendix C** for full list).

#### 3.3.6 Commands Menu
SENDCW, QSOB4, direct command entry.

#### 3.3.7 Tools Menu
POST integration, log utilities.

#### 3.3.8 Net Menu
Multi-op network functions: connect, sync logs (Ctrl-Alt-S), time sync (Ctrl-Alt-T),
send report to GETSCORES.ORG (Shift-Ctrl-8), Intercom (Shift-Ctrl-7).

#### 3.3.9 Help Menu
About, online help link.

---

# PART III — BASIC OPERATING

## Chapter 4 — Your First QSOs

### 4.1 First QSO in CQ Mode

*(See Figures 2-1 through 2-3 in original manual)*

The CQ operating sequence is designed to be completed in as few as **six keystrokes**
for a four-character callsign:

1. Press **F1** to send your CQ message
2. Type the calling station's callsign
3. Press **Enter** → TR4W sends the callsign and your exchange
4. Copy the incoming exchange (zone/section is pre-filled automatically)
5. Press **Enter** again → logs the QSO and sends your QSL message

For maximum speed, **AUTO SEND CHARACTER COUNT** can start CW transmission after
a programmable number of characters are typed. **AUTO CALL TERMINATE** ends the
call sending automatically.

### 4.2 First QSO in S&P Mode

*(See Figures 2-4 through 2-6)*

Press **Tab** to enter S&P mode. Type the callsign and press **Enter**:

- If the station is new → sends your call
- If the station is a dupe → announces DUPE

Press **Enter** again after copying the exchange to log the QSO and send your
exchange. A footswitch can substitute for the Enter key throughout.

---

## Chapter 5 — Regular Operation

### 5.1 Selecting a Supported Contest

See Section 2.5. Ensure all startup checkboxes and CATEGORY fields are filled in
correctly — they populate the Cabrillo header used by the contest robot.

### 5.2 Custom Messages

TR4W ships with default contest messages but they should be customized. Press
**Alt-P** to open the Memory Program Function window. Messages are grouped as
**CQ**, **Exchange**, and **Other**.

> **TIP:** Messages must be entered in **UPPER CASE**.
> **TIP:** Hotkey **Ctrl-Shift-2** toggles the Function Keys display.

#### 5.2.1 Message Symbol Reference

| Symbol | Function |
|---|---|
| `#` | Passes QSO number (can use `#+1` or `#-1`) |
| `@` | Sends callsign from the Call window |
| `=` | Sends greeting and name (e.g., GM JOHN) |
| `~` | Adds a full space at end of message |
| `^` | Passes name from TRMASTER database |
| `&` | Sends characters from keyboard until Enter/Escape |
| `>` | Transmits appropriate greeting only (GM/GA/GE) |
| `!` | Sends MY CALL (your contest callsign) |
| `\` | Half-space |
| `[` | Clears RIT detuning (Kenwood/Yaesu) |
| `+` | End of message (AR) |
| `*` | End (SK) |
| `=` | Double dash (BT) |
| `?` | QRL? |

#### 5.2.2 Editing CQ Messages (Alt-P → C)

Example: To add a half-space between CQ and TEST in the F1 message,
change `CQTEST` to `CQ\TEST`. Give the key a caption (e.g., "CQ") then click OK.

#### 5.2.3 Editing QSL Messages

Alt-P → Other → QSL CW MESSAGE. Add `[` to reset RIT at the end of the QSL.
Note: not all transceivers support the RIT reset command.

### 5.3 Sending Commands to the Rig

When the radio is connected via CAT, embed control sequences in messages using
ASCII control characters (ETX=03, EOT=04):

| Command | Syntax |
|---|---|
| Send string on active radio | `[ETX]SRS string[EOT]` |
| Send string on inactive radio | `[ETX]SRSI string[EOT]` |
| Send to Radio 1 specifically | `[ETX]SRS1 string[EOT]` |
| Send to Radio 2 specifically | `[ETX]SRS2 string[EOT]` |

When programming via Alt-P, enter control characters using **Ctrl-P** then the
control character. CTRLC=0x03, CTRLD=0x04.

### 5.4 Kenwood CAT Command Reference

Selected commands (full list in original manual Section 2.3.4):

| Action | CAT String |
|---|---|
| UP (mic up) | `[ETX]SRSUP[EOT]` |
| DOWN (mic down) | `[ETX]SRSDN[EOT]` |
| Filter 1=0.5kHz, Filter 2=0.5kHz | `[ETX]SRSFL009009[EOT]` |
| Filter 1=2.4kHz, Filter 2=0.5kHz | `[ETX]SRSFL007009[EOT]` |
| VFO A mode | `[ETX]SRSFR0[EOT]` |
| VFO B mode | `[ETX]SRSFR1[EOT]` |
| CW mode | `[ETX]SRSMD3[EOT]` |
| LSB mode | `[ETX]SRSMD1[EOT]` |
| USB mode | `[ETX]SRSMD2[EOT]` |
| RIT ON | `[ETX]SRSRT1[EOT]` |
| RIT OFF | `[ETX]SRSRT0[EOT]` |
| Clear RIT/XIT | `[ETX]SRSRC[EOT]` |
| XIT ON | `[ETX]SRSXT1[EOT]` |
| XIT OFF | `[ETX]SRSXT0[EOT]` |
| TX ON | `[ETX]SRSTX[EOT]` |
| RX ON | `[ETX]SRSRX[EOT]` |

### 5.5 Personalized Greetings

Messages can include operator names and time-appropriate greetings:

- `^` — name from TRMASTER (must be customized in TRMASTER)
- `=` — GM/GA/GE based on time + name (if known)
- `>` — greeting only (no name)

Country-specific greetings override the defaults via **HELLO.DAT** in the TR4W
working directory. Format: `countryAbbreviation[space]greeting`, one per line.

Example HELLO.DAT entries:

```
DL MOIN
EA GRS
F BJR
LA HEI
OH HEI
OK AHOJ
OM AHOJ
SM HELLO
VK GDAY
```

### 5.6 Alarms & Wake-Up Timeout

TR4W tracks minutes since last QSO. Set **WAKE UP TIME OUT = X** (via Ctrl-J)
where X is the elapsed minutes threshold. TR4W will beep every minute until
another station is worked.

### 5.7 Notes

Press **Ctrl-N** during a contest to log a timestamped note. At contest end:
File → Export → Notes → writes **NOTES.TXT** to the current contest directory.
Useful for noting band conditions, busted calls, or operating decisions.

---

# PART IV — ADVANCED OPERATING FEATURES

## Chapter 6 — Bandmap

The bandmap is central to identifying calls and their frequencies on a band.
Entries come from DX Cluster spots or from the operator's manual entries while
tuning. Activate via Ctrl-J **BAND MAP ENABLE TRUE**. Toggle window with
**Ctrl-Shift-[period]**.

### 6.1 Spot Aging and Color Coding

| Age | Display |
|---|---|
| Newest | White text on black background |
| ~1 min | Yellow |
| Aging | Gradually fades toward background color |
| Expired | Disappears (governed by BAND MAP DECAY TIME) |

### 6.2 Bandmap Navigation

- **Mouse click** on a spot — sets radio VFO + loads call into Call window
- **Ctrl-End** — moves keyboard cursor into bandmap
- **Arrow keys** — move spot cursor
- **Enter** (when cursor in bandmap) — tunes radio to spot frequency
- **Delete** — removes selected spot
- **Escape** — moves cursor back to Main Window
- **D** — toggles dupe display
- **M** — toggles all-modes display
- **B** — toggles all-bands display

> If spot has QSX (split) data, the transceiver enters split-frequency mode
> automatically and is ready to transmit on the split frequency.

### 6.3 Bandmap Configuration Statements

| Statement | Default | Purpose |
|---|---|---|
| BAND MAP ENABLE | FALSE | Enable/disable bandmap |
| BAND MAP DECAY TIME MM | 60 | Minutes before a spot expires |
| BAND MAP GUARD BAND NNN HZ | 200 | Frequency window for auto-call loading |
| BAND MAP DUPE DISPLAY | TRUE | Show/hide dupe spots |
| BAND MAP CALL WINDOW ENABLE | TRUE | Auto-load call when tuned near spot |
| CUTOFF FREQUENCY BAND MAP | varies | CW/SSB split frequency by band |
| ASK FOR FREQUENCIES | FALSE | Prompt for freq when no CAT |

### 6.4 Default CW/SSB Split Frequencies

| Band | SSB Cutoff (Hz) |
|---|---|
| 160 m | 1,840,000 |
| 80 m | 3,700,000 |
| 40 m | 7,100,000 |
| 30 m | 10,150,000 |
| 20 m | 14,100,000 |
| 17 m | 18,110,000 |
| 15 m | 21,200,000 |
| 12 m | 24,930,000 |
| 10 m | 28,300,000 |
| 6 m | 50,100,000 |
| 2 m | 144,200,000 |

### 6.5 Spotting

When connected to DX Cluster, press the **tilde (~)** key (upper-left of keyboard)
to spot a station. The contest name is automatically added as a comment.

---

## Chapter 7 — DX Cluster

Connect via the built-in Telnet interface. Once connected, spots flow automatically
into the band map and are sorted by frequency. The Net menu provides connect,
disconnect, and cluster command options.

---

## Chapter 8 — SO2R: Two-Radio Operation

### 8.1 Setup and Configuration

Enable full two-radio support:

```
TWO RADIO MODE = TRUE    (via Ctrl-J)
ALT-D ENABLE = TRUE      (via Ctrl-J)
```

Verify setup with **Alt-R** — the active radio display grays out and the inactive
radio becomes un-grayed. Both radio frequencies must display correctly.

**Key hotkeys:**

| Hotkey | Function |
|---|---|
| Ctrl-Alt-1 | Radio 1 setup |
| Ctrl-Alt-2 | Radio 2 setup |
| Ctrl-W | Winkey setup |
| Alt-R | Swap/verify radio focus |

### 8.2 Basic SO2R Operation

Basic SO2R uses the standard **Alt-D** dupe check. On the run (active) radio, enter
a call or press Space for a dupe check. On the S&P (inactive) radio, press **Alt-D**
— this dupe-checks the call AND confirms it is workable on the SP rig.

When ready to call the SP station:

1. Press **Spacebar** — TR4W halts the run CQ and simultaneously calls the station
   on the SP rig
2. If he responds — copy his exchange, press **Enter** to log and QSL; TR4W
   automatically returns to CQ on the run radio

> **TIP:** Set **Ctrl-J AUTO QSO NUMBER DECREMENT = TRUE** for serial-number contests
> so a failed SP attempt doesn't waste a number.
>
> **TIP:** Alt-D automatically adds a bandmap entry for the SP station — makes
> returning to him much easier.

### 8.3 Advanced SO2R Operation

Advanced SO2R exploits programmed Function Keys for fine-grained radio control.
Non-contest-specific F-key settings live in **COMMONMESSAGES.INI** in the main
TR4W folder.

**Programming control characters in F-keys:**
Use `03`/`04` notation (hex ETX/EOT) or hold Ctrl and press P, then the character.

**Key SO2R message commands:**

| Code | Action |
|---|---|
| `01CQ` | Send CQ on the **inactive** radio without switching focus |
| `SWAPRADIOS` | Swap active/inactive radio focus |
| `015nn` | Send exchange repeat on inactive radio |
| `CQMODE` | Set key context to CQ mode |
| `SAPMODE` | Set key context to S&P mode |

**Scenario — long exchange on SP, need to hold run frequency:**

1. Copy long SP exchange; use **Ctrl-A** (`01CQ`) to send CQ on run radio without
   switching focus
2. Press **Enter** to QSL the SP exchange
3. Press the **SWAPRADIOS** Function Key, enter SP caller's call, press **Enter**

---

## Chapter 9 — Multi-Operator Operation

TR4W supports networked multi-operator operation using a TCP/IP client/server model.
All stations share log data in real time. Use the **Net menu** to connect, and
**Ctrl-Alt-S** to compare and synchronize logs. **Ctrl-Alt-T** synchronizes time
across all stations.

---

## Chapter 10 — RTTY Operation

RTTY is supported via the **MMTTY engine**. Configure the MMTTY path via Ctrl-J,
then select RTTY as your mode. RTTY QSOs are logged and scored the same as CW/SSB.

---

## Chapter 11 — DVP Audio Messages

### 11.1 Audio File Format and Location

All audio files are standard **.WAV** format. Default location is the **DVP\\**
subfolder of the TR4W directory (set via `DVP PATH` Configuration Statement).

### 11.2 Using the DVP During a Contest

Map F-keys to .WAV files in CONTESTNAME.CFG:

```
CQ SSB MEMORY F1 CQF1.WAV
QSL SSB MESSAGE QSL.WAV
CQ SSB EXCHANGE CQEXCHNG.WAV
```

### 11.3 Automatic Generation of DVP Audio Messages

Enable with:

```
USE RECORDED SIGNS = TRUE
```

Pre-record 37 files (A.WAV through Z.WAV, 0.WAV through 9.WAV, and .WAV for slash)
using phonetic pronunciation. Store in `DVP\LETTERSANDNUMBERS\`.

Full callsigns: `DVP\FULLCALLSIGNS\CALLSIGN.WAV` (e.g., `UA4WLI.WAV`)
Serial numbers: `DVP\FULLSERIALNUMBERS\1.WAV`, `2.WAV`, etc.

> **TIP:** Concatenate files for two-digit numbers (e.g., `98.WAV` = `9.WAV` + `8.WAV`)
> to reduce the total number of recordings needed.

### 11.4 Process: Working on the Air with DVP Audio

| Event | Audio Sent |
|---|---|
| F1 pressed (CQ) | `CQF1.WAV` — e.g., "United Alpha Four Whiskey Lima Italy Contest" |
| Call typed + Enter | Letter/digit WAV files spell out the callsign phonetically |
| Exchange sent | `CQEXCHANGE.WAV` |
| QSL | `QSL.WAV` — e.g., "Thanks United Alpha Four Whiskey Lima Italy Contest" |

---

## Chapter 12 — VHF/UHF Operation

Rover stations are logged with the suffix **R** appended to their callsign.
When a rover is worked a second time on a given band/mode, TR4W displays a list of
previously worked grid squares. A new grid square = full QSO points; duplicate grid = 0 points.

Toggle FM mode with **Alt-M**. FM QSOs are treated like SSB for dupe/multiplier checking.
Disable HF bands for VHF/UHF contests with `HF BAND ENABLE = FALSE` (default for VHF/UHF contests).

---

## Chapter 13 — Farnsworth CW

Farnsworth spacing adds extra space *between* characters while keeping character
speed constant (typically 18 WPM). Useful for CW training and some on-air situations.

| Statement | Default | Purpose |
|---|---|---|
| FARNSWORTH ENABLE | FALSE | Enable/disable Farnsworth spacing |
| FARNSWORTH SPEED | 25 WPM | Speed at which Farnsworth effect activates |

**Dynamic control during CW sending:**

| Hotkey | Action |
|---|---|
| Ctrl-2 | Toggle FARNSWORTH ENABLE |
| Ctrl-3 | Set Farnsworth speed to 25 WPM |
| Ctrl-4 | 35 WPM |
| Ctrl-5 | 45 WPM |
| Ctrl-6 | 55 WPM |
| Ctrl-7 | 75 WPM |
| Ctrl-8 | 95 WPM |

> **NOTE:** The Ctrl-[character] sequences use ASCII ESC (0x1B = 027 decimal).
> On non-English keyboards, produce ESC by holding Alt and pressing 027 on the keypad.

---

## Chapter 14 — MP3 Contest Recording

### 14.1 Setup

1. Place **lameenc.dll** in the TR4W folder or Windows System32 folder
   (download from http://tr4w.net/otherfiles)
2. Connect radio audio output to PC sound card via hardware interface
3. Open MP3 Recorder: **Windows menu → MP3 Recorder** or **Shift-Ctrl-0**

### 14.2 Configuration Statements

| Statement | Default | Purpose |
|---|---|---|
| ENABLE MP3 RECORDER | FALSE | TRUE = start recording on window open |
| MP3 RECORDER BITRATE | 8 | Minimum 8 for CW; minimum 32 for SSB |
| RECORDER MP3 SAMPLE RATE | 8000 | Sample rate |
| MP3 PATH | MP3\ | Storage folder for .mp3 files |
| MP3 RECORDER DURATION | EACH QSO | EACH QSO / EACH HOUR / NON-STOP |

### 14.3 File Naming

- **EACH QSO:** `YYYYMMDDHHMMSS[BAND]m[CALLSIGN].MP3`
- **EACH HOUR:** `TEMPHHDD.MP3`
- **NON-STOP:** Single continuous file

> SSB recordings are ~4× larger than CW recordings at the same duration.

---

## Chapter 15 — Hardware Accessories

### 15.1 Foot Switch

The foot switch connects via LPT port and substitutes for the Enter key, making
it possible to log a QSO with zero hand movement from the keyer paddles.
Configure foot switch function via Ctrl-J.

### 15.2 Rotator Control

TR4W supports antenna rotator control. Beam headings and sunrise/sunset times
are automatically displayed for each country as you work them.

### 15.3 Antenna Band Decoder

Antenna band decoder output is available via the LPT port for automatic antenna
switching when changing bands.

---

# PART V — CONTEST CONFIGURATION

## Chapter 16 — Supported Contests

TR4W supports over 140 contests. Select at startup or use the CONTEST
Configuration Statement in your .CFG file. See **Appendix E** for a full list.

### 16.1 Country List Updates

TR4W uses the standard **CTY.DAT** file. When prefix or country assignments change:
open TR4W → Commands → Country List Changes to update.

---

## Chapter 17 — Custom (Non-Supported) Contest Configuration

### 17.1 Overview

When a contest is not in TR4W's supported list, build a custom .CFG file based
on a supported contest that uses the **same exchange structure**.

### 17.2 New Contest Setup Procedure

1. Identify a supported contest with a matching exchange (see Section 17.4.4)
2. Initialize TR4W with that supported contest; fill in call and parameters; exit
3. In the TR4W folder, **rename the created contest folder** to your new contest name
4. Rename the .CFG file inside to match
5. Open `SETTINGS\TR4W.INI`, find **LATEST CONFIG FILE**, and replace the contest
   name in both locations with your new contest name (keep year and callsign the same)
6. Delete all files in the new contest folder except the .CFG file
7. Replace all .CFG content with the template (Section 17.3)
8. Open TR4W — note the DOMESTIC FILENAME value shown in Ctrl-J (line 71);
   write it down for use in step 9
9. Exit TR4W; update DOMESTIC FILE NAME in the .CFG with the string from step 8

> **CRITICAL:** The MY CALL statement must immediately follow the COMMANDS statement.

### 17.3 Configuration File Template

```
COMMANDS
MY CALL [YOUR CALL]
CONTEST NEQP
CONTEST NAME NEW CONTEST
CONTEST TITLE NEW CONTEST
DOMESTIC FILE NAME [see step 8 above]
DOMESTIC MULTIPLIER NONE
DX MULTIPLIER NONE
CATEGORY-ASSISTED NON-ASSISTED
CATEGORY-BAND ALL
CATEGORY-MODE MIXED
CATEGORY-OPERATOR SINGLE-OP
CATEGORY-POWER HIGH
CATEGORY-STATION FIXED
QSO BY BAND FALSE
QSO BY MODE FALSE
MULTIPLE BANDS TRUE
MULTIPLE MODES TRUE
QSO POINT METHOD NONE
MY CHECK NONE
MY CONTINENT NONE
MY COUNTRY K
MY FD CLASS NONE
MY GRID NONE
MY IOTA NONE
MY NAME NONE
MY POSTAL CODE NONE
MY PREC NONE
MY QTH NONE
MY SECTION NONE
MY STATE NONE
MY ZONE NONE
```

### 17.4 Configuration Statement Details

#### 17.4.1 Category Statements

```
CATEGORY-ASSISTED    NON-ASSISTED
CATEGORY-BAND        ALL
CATEGORY-MODE        MIXED
CATEGORY-OPERATOR    SINGLE-OP
CATEGORY-POWER       HIGH
CATEGORY-STATION     FIXED
```

#### 17.4.2 DX Multiplier Choices

| Value | Meaning |
|---|---|
| NONE | No DX multipliers |
| ARRL DXCC WITH NO USA OR CANADA | Standard ARRL DX |
| CQ DXCC | CQ WW style |
| CQ EUROPEAN COUNTRIES | European-only mults |
| NORTH AMERICAN ARRL DXCC WITH NO USA CANADA OR KL7 | NA-only |
| PACC COUNTRIES AND PREFIXES | PACC contest |
| BLACK SEA COUNTRIES | Black Sea contest |
| *(+ 14 more options)* | |

#### 17.4.3 Exchange Received Choices (partial)

| Value | Example Contest |
|---|---|
| RST DOMESTIC OR DX QTH | State QSO party |
| RST CQ ZONE | CQ WW |
| RST ITUZ | IARU HF |
| RST ARRL SECTION | ARRL Sweepstakes exchange part |
| RST NAME | Simple ragchew contest |
| RS GRID | VHF contest |

#### 17.4.4 QSO Scoring Statements

```
QSO BY BAND          FALSE   (TRUE if same station can be worked on multiple bands)
QSO BY MODE          FALSE   (TRUE if same station can be worked on multiple modes)
MULTIPLE BANDS       TRUE    (FALSE for single-band contests)
MULTIPLE MODES       TRUE    (FALSE for single-mode contests)
QSO POINT METHOD     NONE
```

#### 17.4.5 MY Statements

Set MY COUNTRY to the country prefix (e.g., K for USA, VE for Canada).
MY QTH = your county/state/province as required by the contest.

### 17.5 Creating Domestic .DOM Files

.DOM files live in the **DOM\\** directory and validate domestic exchange values.
Use the DOMESTIC FILE NAME statement to point TR4W to the correct file.
The DOMESTIC MULTIPLIER setting activates domestic multiplier scoring.

---

# PART VI — TRMASTER DATABASE

## Chapter 18 — TRMASTER Basics

**TRMASTER.DTA** is the callsign database that enables TR4W to display and prefill
operator names, QTH, grid, Sweepstakes check, FOC numbers, and more. It is NOT
shipped with TR4W — download the community-maintained version:

1. Navigate to **http://www.supercheckpartial.com**
2. Right-click **MASTER.DTA** → Save As → save to TR4W directory
3. Rename the file to **TRMASTER.DTA** (not MASTER.DTA)

The SCP (System Check Partial) window is toggled with **Shift-Ctrl-3** or via
Windows → SCP. Set `SCP MINIMUM LETTERS` (Ctrl-J) to the number of characters
typed before SCP activates (recommended: 3).

> A customized TRMASTER.DTA placed in a **contest directory** takes precedence over
> the global one in the TR4W root directory.

---

## Chapter 19 — Building and Customizing TRMASTER.DTA

### 19.1 Installing POST.EXE

Download from **http://trlog.com/free.shtml** → right-click
`http://www.trlog.com/post672a.zip` → Save As. Extract **POST.EXE** and **POST.OVR**.

> **WARNING:** POST will NOT run on Windows 7 x64. Use a 32-bit Windows environment.

### 19.2 POST Field Type Reference

| Field | Max Chars | POST Type Code |
|---|---|---|
| Name | 12 | 7 |
| Old Call | 12 | — |
| ARRL Section | 5 | — |
| CQ Zone | 2 | — |
| FOC Number | 5 | — |
| Grid | 6 | — |
| ITU Zone | 5 | — |
| SS Check | 2 | 3 |
| QTH | 10 | — |
| Code Speed | 2 | — |
| Ten-Ten Number | 6 | — |
| User Defined 1–5 | 12 | — |

### 19.3 POST Operating Procedure (Name from a File)

1. Start POST.EXE → enter `UEFF`
2. Enter filename (e.g., `myfile.txt`) → answer `n` to "Is this a TR log?"
3. The column indicator displays. Enter the **starting column for callsigns** → Enter
4. Enter the **starting column for the data field** (e.g., name starts at column 8) → Enter
5. Enter rows to skip (e.g., 0 for no headers, or 13 to skip Cabrillo headers) → Enter
6. Enter the field type code (e.g., `7` for Name) → Enter
7. Answer `n` if no more fields; answer `y` to set overwrite flags
8. Press `x` three times to exit POST
9. Rename `TRMASTER.DTA.BAK` as backup; copy new `TRMASTER.DTA` into TR4W directory

> **TIP:** POST requires **fixed-width columns**. Use LibreOffice to normalize
> variable-width data: open the file, arrange columns, then **Save As** with
> "Edit filter settings" checked to specify fixed-column output.

### 19.4 Processing a Cabrillo Log

Cabrillo headers must be removed or skipped:

- **Easy method:** Open log in Notepad, delete the first N header lines, Save As new filename
- **POST method:** When prompted for rows to skip, enter the count of header lines (e.g., 13)

Typical Cabrillo column positions:
- Callsign starts at column 56
- CHECK field at column 74
- SECTION field at column 77

### 19.5 Processing a Club Roster (HTML/Web Table)

1. Navigate to the roster URL; right-click → Save As → save as `.htm`
2. Open in LibreOffice Calc
3. Remove header rows: hold Ctrl, click row numbers, press Ctrl-[minus] to delete
4. Remove unneeded columns: Ctrl-click column headers, press Ctrl-[minus]
5. Copy/paste remaining data to Notepad; Save As fixed-width `.txt` in POST directory
6. Run POST as above

### 19.6 Overwrite Flags

When POST asks about overwrite flags, answer `y` and set **Name overwrite = TRUE**
to ensure existing entries are updated with new data. For Sweepstakes SECTION, set
overwrite TRUE when using current-year data.

### 19.7 Activating TRMASTER Display in TR4W

| Ctrl-J Setting | Value | Effect |
|---|---|---|
| USER INFO SHOWN | NAME | Shows name in User Info window |
| USER INFO SHOWN | CUSTOM | Shows custom string (defined below) |
| CUSTOM USER STRING | CHECK SECTION | Displays e.g., "61 SCV" |
| SAY HI RATE CUTOFF | N | Limits automatic greeting to stations worked fewer than N times |

---

## Chapter 20 — INITIAL.EX Exchange Prefill File

### 20.1 INITIAL.EX vs. TRMASTER.DTA

**INITIAL.EX takes precedence** over TRMASTER.DTA when both contain the same
callsign and both are activated. Use INITIAL.EX when you want specific exchange
data prefilled into the Exchange window.

### 20.2 Building an INITIAL.EX

Format: `CALLSIGN[space]EXCHANGE DATA` — one entry per line, fixed columns.

LibreOffice workflow:
1. Open the source data (roster, prior log, spreadsheet)
2. Keep only the CALL, NAME, and exchange columns
3. Copy/paste to Notepad → Save As `INITIAL.EX` in the contest directory

After running a contest, TR4W will export a **CUSTOM INITIAL.EX** combining the
original INITIAL.EX with new exchange data from the current log.

### 20.3 Activating INITIAL.EX

```
Ctrl-J → INITIAL EXCHANGE FILENAME → double-click → browse to INITIAL.EX
```

For Sweepstakes prefill:

```
Ctrl-J → INITIAL EXCHANGE = CUSTOM
Ctrl-J → CUSTOM INITIAL EXCHANGE STRING = CHECK SECTION
```

> **TIP:** Ensure `SCP MINIMUM LETTERS` is NOT set to zero or SCP will not function.

---

# PART VII — POST-CONTEST

## Chapter 21 — Entering a Hand Log

When entering a log after the contest ends:

| Ctrl-J Setting | Recommended Value | Purpose |
|---|---|---|
| AUTO TIME INCREMENT | X minutes | Auto-increments time after each logged QSO |
| AUTO DUPE ENABLE | FALSE | Allows entry of contacts that would normally be flagged as dupes |
| INCREMENT TIME ENABLE | TRUE | Allows manual time adjustment via Alt-[arrow] keys |

---

## Chapter 22 — Reports

Access via **File → Reports** (or the Tools menu). Available reports:

| Report | Description |
|---|---|
| All Callsigns | Full log listing |
| Band Changes | Operator band-change log |
| Continent List | QSOs/mults by continent |
| First Callsign Worked in Each Country | Country-by-country first contact |
| First Callsign Worked in Each Zone | Zone-by-zone first contact |
| QSOs by Country by Band | Cross-tabulation matrix |
| Score by Hour | Running hourly totals — useful for 3830 reports |
| Summary Sheet | Competition summary (suitable for 3830 posting) |

---

## Chapter 23 — Log Export

### 23.1 ADIF Export

ADIF (Amateur Data Interchange Format) is the universal log exchange format.
TR4W exports to `[YOURCALL].ADI` in the contest directory.

**Key uses:**
- Import into Logger32 or LoTW
- Re-import back into TR4W to restore a contest log

> **NOTE:** The ONLY way to reload a past contest back into TR4W is via ADIF import.
> Export your ADIF immediately after every contest.

### 23.2 Cabrillo Export

Cabrillo is what you email to the contest sponsor. TR4W exports to
`[YOURCALL].LOG` in the contest directory.

**Before exporting, fill out all Station Information fields** — these become the
Cabrillo header used by the contest robot to validate your entry. Most fields are
required. Rename the file to a unique name before submission (e.g., `N4AF-CQ-WW-CW-2024.LOG`).

### 23.3 Initial Exchanges List Export

TR4W exports `INITIAL.EX` from the current log's exchange data.
If an INITIAL.EX already existed, the output is **CUSTOM INITIAL.EX** — a merged
file combining both old and new data.

On your next run of the same contest, point `INITIAL EXCHANGE FILENAME` (Ctrl-J)
to `CUSTOM INITIAL.EX` for maximum exchange prefill coverage.

---

# APPENDIX A — Configuration Statements

*(Full alphabetical table from original manual Section 9 / Appendix A)*

Most Configuration Statements can be changed **at runtime** using **Ctrl-J** to open
the Configuration Statements window. Changes take effect immediately without
restarting TR4W.

---

# APPENDIX B — Suggested Interface Circuits

*(Original Appendix B — Section 7 of original manual)*

## B.1 CW Keying — Serial Port

## B.2 CW Keying — Parallel Port (LPT)

## B.3 PTT Control

## B.4 CAT Control Interface

## B.5 Audio Interface for DVP/MP3 Recording (UU2JJ Circuit)

The UU2JJ interface provides transformer isolation to eliminate ground loops and
level-matching between radio audio output and PC sound card input.

---

# APPENDIX C — Keyboard Reference

*(Original Appendix C — Section 8.1–8.6 of original manual)*

## C.1 Alt Key Commands
## C.2 Ctrl Key Commands
## C.3 Additional Ctrl Key Commands

| Shortcut | Description |
|---|---|
| Ctrl-1 | Number of QSO |
| Ctrl-2 | Call |
| Ctrl-3 | CW speed |
| Ctrl-4 | Frequency range |
| Ctrl-7 | Clear multipliers table |
| Ctrl-8 | Reduce auto-QSL interval |
| Ctrl-9 | Cursor in map window range |
| Ctrl-PgDn | Reduce CW speed on idle radio |
| Ctrl-PgUp | Increase CW speed on idle radio |

## C.4 Shift+Ctrl Key Commands

| Shortcut | Description |
|---|---|
| Shift-Ctrl-[period] | Band map window toggle |
| Shift-Ctrl-0 | MP3 Recorder |
| Shift-Ctrl-1 | Dupe sheet |
| Shift-Ctrl-2 | Function Keys display |
| Shift-Ctrl-3 | TRMASTER.DTA / SCP window |
| Shift-Ctrl-4 | Defaults |
| Shift-Ctrl-5 | Radio 1 |
| Shift-Ctrl-6 | Radio 2 |
| Shift-Ctrl-7 | Intercom |
| Shift-Ctrl-8 | Send report to GETSCORES.ORG |
| Shift-Ctrl-9 | Station window |
| Shift-Tab | CQ mode |

## C.5 Ctrl+Alt Key Commands

| Shortcut | Description |
|---|---|
| Ctrl-Alt-1 | Radio 1 setup |
| Ctrl-Alt-2 | Radio 2 setup |
| Ctrl-Alt-M | Tile windows |
| Ctrl-Alt-S | Compare and sync logs |
| Ctrl-Alt-T | Time synchronization |
| Ctrl-Alt-W | Reset alarm |

## C.6 Special Keys

| Key | Description |
|---|---|
| Del | Delete selected spot |
| Enter | Log QSO and transmit |
| Esc | Exit S&P mode |
| Ins | Toggle insert/replace |
| Pause | Return focus to main program window |
| PgDn | Reduce CW speed |
| PgUp | Increase CW speed |
| Tab | Enter S&P mode |
| ~ (tilde) | Send spot to DX Cluster |

---

# APPENDIX D — Supported Transceivers

*(Original Appendix C Section 8.7)*

Supported manufacturers: **Elecraft, Icom, Japan Radio (JRC), Kenwood, Ten-Tec, Yaesu**.
Both serial COM port and USB-to-Serial adapters are supported.
*(Full transceiver model list from original manual)*

---

# APPENDIX E — Supported Contests

*(Original Appendix C Section 8.8)*

Over 140 contests supported. Full alphabetical list with contest name tokens
used in .CFG files appears here.
*(Full contest list from original manual)*

---

# APPENDIX F — Sub-Window Default Colors

*(Original Appendix C Section 8.9)*

Full table of default foreground/background colors for all TR4W sub-windows,
with the Configuration Statement name for overriding each entry.
*(Full color table from original manual)*

---

*TR4W User Manual — Reorganized Edition*
*Outline and content restructuring: April 2026*
*Based on TR4W User Manual v4.01b — June 11, 2014*
*Original contributors: Larry Tyree N6TR, Doc Evans N7DR, Dmitriy Gulyaev UA4WLI*
*Original editor: Howard Hoyt N4AF*
