![Tests](https://github.com/refaim/MobStats/workflows/Tests/badge.svg)

Vanilla WoW 1.12.1 and Turtle WoW addon. Displays mob stats in a human-friendly form in the game tooltip. Supports all game client languages.

## Screenshots

![boar.png](boar.png)
![wendigo.png](wendigo.png)

## Version History

### v1.7 (Feb 6, 2026)
* Add localization support (deDE, enUS, esES, frFR, koKR, ptBR, ruRU, zhCN, zhTW)
* Fix resistance lookup bug that would break with non-English locales

### v1.6 (Feb 5, 2026)
* Improve resistance display when 5 of 6 resistances are identical
* Handle unknown mob levels properly
* Fix nil armor edge case
* Add test suite with GitHub Actions CI

### v1.5 (Aug 16, 2025)
* Support Turtle WoW 1.18.0

### v1.4 (Jun 6, 2025)
* Fix average resistance calculation

### v1.3 (May 11, 2024)
* Display zero armor as "None"
* Treat "?? (Boss)" level mobs as 63 lvl mobs

### v1.2 (Mar 10, 2024)
* Fix holy resistance calculation for Turtle WoW server
* Fix resistance tooltip compression algorithm

### v1.1 (Mar 9, 2024)
* Handle "skull"-level enemies properly
* Reduce visual clutter by improving resistance display strings compression algorithm
* Color the comma the same color as the text

### v1.0 (Mar 7, 2024)
* Initial release
