.pragma library

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  ARROW-KEY MOVEMENT ACROSS TILES.
//
//  Two layouts:
//    ruch()  - the program grid (kafle/Uzbrojenie.qml). Tiles sit in blocks one
//              below another, and each block is laid out from the left in rows of
//              "kolumny" items. The index counts through the blocks in order.
//    zawin() - the single tile row at the bottom of the screen (kafle/RzadKafli.qml),
//              wrapping around at the ends.
//
//  A separate file, without QML, so it can be tested on its own.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

// indeks  - current tile, counted across all blocks
// dx, dy  - -1 / 0 / +1
// sekcje  - number of tiles in successive blocks, e.g. [5, 37]
//
// Returns the new index, or -1 when there are no tiles at all.
function ruch(indeks, dx, dy, sekcje, kolumny) {
    const razem = sekcje.reduce((a, b) => a + b, 0);
    if (razem === 0) return -1;
    if (indeks < 0 || indeks >= razem) return 0;

    // Sideways - simply the next or previous one, also across the block
    // boundary, without wrapping at the ends.
    if (dx !== 0) return Math.max(0, Math.min(razem - 1, indeks + dx));

    // Block, row and column of the current tile. Empty blocks are skipped.
    let blok = 0;
    let start = 0;
    while (indeks >= start + sekcje[blok]) {
        start += sekcje[blok];
        blok++;
    }
    const lokalny = indeks - start;
    const wiersz = Math.floor(lokalny / kolumny);
    const kolumna = lokalny % kolumny;

    if (dy > 0) {
        // Next row of this block. A shorter last row - onto its last
        // tile, instead of not moving at all.
        const nastepny = (wiersz + 1) * kolumny;
        if (nastepny < sekcje[blok])
            return start + Math.min(nastepny + kolumna, sekcje[blok] - 1);

        // First row of the next non-empty block, same column.
        let poczatek = start + sekcje[blok];
        for (let b = blok + 1; b < sekcje.length; b++) {
            if (sekcje[b] > 0) return poczatek + Math.min(kolumna, sekcje[b] - 1);
            poczatek += sekcje[b];
        }
        return indeks;
    }

    if (dy < 0) {
        if (wiersz > 0) return start + (wiersz - 1) * kolumny + kolumna;

        // Last row of the previous non-empty block, same column.
        let poczatek = start;
        for (let b = blok - 1; b >= 0; b--) {
            poczatek -= sekcje[b];
            if (sekcje[b] > 0) {
                const ostatni = Math.floor((sekcje[b] - 1) / kolumny);
                return poczatek + Math.min(ostatni * kolumny + kolumna, sekcje[b] - 1);
            }
        }
        return indeks;
    }

    return indeks;
}

// A step in the tile row with wrapping: left from the first lands on the
// last, right from the last - on the first. That is how a menu tab moves
// in a gamepad-driven game; the app grid (ruch above) deliberately does NOT
// wrap, because there a jump from the end to the start of the list loses orientation.
//
// indeks - current tile, krok - -1 / +1, liczba - how many tiles in the row.
// Returns the new index, or -1 when the row is empty.
function zawin(indeks, krok, liczba) {
    if (liczba <= 0) return -1;
    return ((indeks + krok) % liczba + liczba) % liczba;
}
