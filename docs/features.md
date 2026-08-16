# Every feature, in full

Complete as of version 1.0.0. If something is in the app, it is in here.

---

## 1. Drawing numbers

- **One button draws the next number.** Full width, 76 points tall at minimum,
  sized for a thumb rather than a mouse.
- **Numbers never repeat.** Each draw picks only from numbers that have not
  come up, so there is nothing for the caller to keep track of.
- **Cryptographically seeded randomness.** Uses `Random.secure()`, not the
  default generator, so no sequence is predictable from an earlier one.
- **The live number fills the screen.** Up to 132 points, in the accent
  colour, readable from the back of a hall.
- **The number animates in.** It scales up from 72% while the previous one
  fades, so a glance tells you a new number has landed.
- **It shrinks to fit rather than overflowing.** On a short screen the number,
  and the bingo letter above it, scale down together as one block.
- **Double taps are ignored.** For 260 ms after a draw further taps are
  dropped, so a fast tapper cannot outrun the number appearing.
- **The button never greys out mid-game.** It stays live-looking through that
  lock, because a button that dims on every tap reads as broken.
- **The bag is counted on the button.** "67 left in the bag", updated per draw.
- **The game ends cleanly.** After the last number the button becomes "NEW
  GAME" and reports "All 90 called".

## 2. The two games

- **Housie / Tambola, 1 to 90.**
- **Bingo, 1 to 75**, with B, I, N, G and O.
- **Switchable in settings**, at any time.
- **Switching asks first** if a game is under way, because the numbers already
  called do not fit the other board.
- **Bingo shows its letter.** The current number displays as `G 47`, on the
  board, in the history and in the big display.

## 3. The board

- **Every number in the range is on screen at once.** Nothing scrolls, in
  either orientation, on any screen size.
- **Cells size themselves.** The board is given a box and works out its own
  cell dimensions to fill it, so it adapts from a small cheap phone to a
  tablet without a special case.
- **Three states per cell**: not yet called, called, and the one showing now.
  Each has its own fill and text colour, and the current cell also carries a
  ring.
- **Cells animate as they fill**, over 260 ms.
- **Tabular figures**, so digits line up in columns rather than jittering.
- **Housie reads across** in nine rows of ten.
- **Bingo reads down** five lettered columns when upright.
- **Bingo turns on its side when the screen does**: five lettered rows of
  fifteen, the traditional flashboard, because fifteen rows will not fit a
  sideways phone legibly.

## 4. Call history

- **Every call, in order, newest first**, as a horizontally scrolling strip.
- **The current number is highlighted** in the strip, so it can never
  disagree with the big display.
- **Shown in a raised tray** with its own surface colour and a hairline
  border, so it reads as a separate panel and not one more row of the board.
- **Empty state**: "Called numbers appear here".

## 5. Undo

- **Takes back the last call**, and the number returns to the bag and can be
  drawn again.
- **Asks first**, naming the number: "47 goes back in the bag and can come up
  again later."
- **Greyed out** when there is nothing to undo.
- **Stops the voice** mid-word if it is still speaking.

## 6. Starting over

- **Reset asks first**, and says how many numbers will be lost.
- **Greyed out** on a board that is already empty.
- **No confirmation on a finished game**, where there is nothing left to lose.
- **Placed at the far end of the header** from the rotate button, and as far
  as the layout allows from the draw button.

## 7. The voice

- **Speaks every number as it is drawn.**
- **English and Hindi**, switchable.
- **Words, not digits.** The app sends "forty-seven" or "सैंतालीस" rather than
  "47", so a number sounds the same on every handset instead of depending on
  how a particular speech engine reads numerals.
- **Hindi is a full ninety-word table**, because Hindi has a distinct word for
  every number to a hundred and there is no rule to generate them.
- **Adjustable speed**, from 0.2 to 0.9.
- **A test button** that speaks a sample without starting a game.
- **The test says ninety-seven**, deliberately. Housie stops at 90 and bingo
  at 75, so the sample can never be mistaken by anyone in the room for a real
  call. The button is labelled "Test:" for the same reason.
- **Changing the speed replays the sample**, so you can hear what you picked.
- **Warns if the language has no voice installed** on the handset, and says
  where to add one.
- **Speaking never blocks the screen.** The number appears first and the
  voice follows.
- **Uses the handset's own speech engine.** Nothing is downloaded and nothing
  is sent anywhere.
- **Can be switched off** entirely.

## 8. Vibration

- **A short pulse on every call.**
- **Two pulses on the last number** of the game.
- **Buzzes once the moment you switch it on**, so you can tell whether this
  handset does anything without starting a game.
- **Drives the motor directly on Android**, rather than going through the
  system's touch-feedback path, which is silently dropped when the handset's
  own touch feedback is off. The app asks for the `VIBRATE` permission for
  this and nothing else.
- **Uses the Taptic Engine on iOS**, where the impact feedbacks feel right and
  a plain vibrate does not.
- **Can be switched off.**

## 9. The screen staying awake

- **Holds the display on during a game**, so it does not lock between calls
  while the phone sits on a table.
- **Only while a game is actually running.** Released on an empty board and
  once the last number is called, rather than burning battery on an idle one.
- **Can be switched off.**

## 10. Rotation

- **Works upright and sideways**, following the handset.
- **A completely different layout sideways**, not a stretched one: board and
  history down the left, the number and the controls down the right, and the
  navigation as a rail on the right hand edge.
- **A rotate button** for handsets with auto rotate switched off. One tap pins
  the app the other way up, another releases it.
- **The same icon and colour at all times.** A control that turns the screen
  should not become a different looking control once it has been pressed.
  Only its tooltip changes.
- **Its icon is a phone, not another circular arrow**, and it sits at the
  opposite end of the header from reset, so the two cannot be confused.
- **The lock is not saved.** It resets to automatic next launch, because a
  phone that opens sideways a week later because of a forgotten tap is a bug
  report.
- **Upside-down portrait is excluded** on purpose.
- **Seamless rotation requested from Android**, so the system skips its
  stretch-and-rotate animation when the app can redraw in time.
- **The window background matches the app** in both themes, so nothing
  flashes the wrong colour mid-turn.

## 11. Appearance

- **Light and dark themes**, plus following the system.
- **One palette definition** drives both, as semantic tokens: background,
  surface, border, text, muted, accent and the called-cell colours.
- **One type scale**, shared by every component, so nothing re-declares a font
  size.
- **No app bar.** The counts row doubles as one; a strip repeating the app's
  own name costs a row of board and says nothing.
- **Progress bar** across the header, animating as the game fills up.
- **Called and remaining counts** either side of the game name.
- **Material 3** throughout, with a generated colour scheme.

## 12. Navigation

- **Three tabs**: Game, Settings, About & support.
- **A bar along the bottom upright, a rail down the right sideways.**
- **Only the visible tab is built**, so a rotation re-lays-out one screen
  rather than three.

## 13. Remembering things

- **The game in progress survives** the app closing, the phone dying and a
  restart. The numbers called come back exactly as they were.
- **Every setting is saved** the moment it changes.
- **A saved game from the other mode is discarded** rather than forced onto a
  board it does not fit.
- **Unreadable saved data opens a fresh game** instead of failing to start.
  Every stored field is type-checked rather than cast, because a cast would
  throw before the first frame and the app would not open at all.

## 14. About and support

- **The app icon, name and publisher** at the top, the same mark as the
  launcher.
- **A support button** that opens the support page in the real browser, never
  an in-app web view, which is what Apple requires for donations.
- **The wording that keeps it a tip**: "A voluntary tip, not a purchase. It
  buys no features, no priority support and no say over the app."
- **What the app promises**: no internet needed, collects nothing, no adverts.
- **A privacy statement in full**, in plain words, in the app.
- **Links** to the store listing, the source on GitHub, and Step Into The Code.
- **A fallback** if no browser will take the link: the address is copied and
  shown, rather than the tap appearing to do nothing.
- **The version number**, checked against pubspec.yaml by a test.

## 15. Privacy

- **No adverts**, and no paid tier that removes them, because there is nothing
  to remove.
- **No analytics and no crash reporting.**
- **No account, ever.**
- **No `INTERNET` permission on Android.** The app could not send anything
  anywhere even if it tried. A test fails if that permission ever appears.
- **One permission in total**: `VIBRATE`, which collects nothing.
- **Everything stays on the handset** and is deleted with the app.
- **Works with no network at all.**

## 16. Accessibility

- **The live number is a screen-reader live region**, announced as it changes.
- **Every control is labelled**, including the draw button, which reads its
  label and its count together.
- **Tooltips** on the icon buttons.
- **Text scales down to fit** rather than overflowing, so a large system font
  setting does not break the layout.
- **Contrast**: the palettes were picked so text on every surface clears the
  usual readability thresholds in both themes.

## 17. One thing that is not written down anywhere in the app

Tap the app icon on the About screen seven times, within three seconds of
each other.

It is not a button, has no ripple, and is hidden from screen readers on
purpose, so nobody trips over it by accident. It clears itself away after four
seconds, or on a tap, and touches nothing else in the app.

## 18. What it deliberately does not do

Listed because each was considered and rejected, not overlooked.

- No adverts, no purchases, no subscription, no unlockables.
- No accounts, no cloud sync, no multi-device play.
- No ticket generation and no prize checking.
- No auto-call timer: a caller sets the pace, not a stopwatch.
- No traditional nickname call-outs ("two little ducks").
- No sound effects beyond the spoken number.
- No named or saved past games; one game at a time.
- No landscape support on the launch screen; the app pins upright while
  starting.
