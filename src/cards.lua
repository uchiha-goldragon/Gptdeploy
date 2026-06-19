local cards = {
    {id = 1, month = 1, suit = "Pine", label = "Crane", type = "bright", value = 20},
    {id = 2, month = 1, suit = "Pine", label = "Poetry", type = "ribbon", value = 5},
    {id = 3, month = 1, suit = "Pine", label = "Pine 1", type = "junk", value = 1},
    {id = 4, month = 1, suit = "Pine", label = "Pine 2", type = "junk", value = 1},

    {id = 5, month = 2, suit = "Plum", label = "Warbler", type = "animal", value = 10},
    {id = 6, month = 2, suit = "Plum", label = "Poetry", type = "ribbon", value = 5},
    {id = 7, month = 2, suit = "Plum", label = "Plum 1", type = "junk", value = 1},
    {id = 8, month = 2, suit = "Plum", label = "Plum 2", type = "junk", value = 1},

    {id = 9, month = 3, suit = "Cherry", label = "Curtain", type = "bright", value = 20},
    {id = 10, month = 3, suit = "Cherry", label = "Poetry", type = "ribbon", value = 5},
    {id = 11, month = 3, suit = "Cherry", label = "Cherry 1", type = "junk", value = 1},
    {id = 12, month = 3, suit = "Cherry", label = "Cherry 2", type = "junk", value = 1},

    {id = 13, month = 4, suit = "Wisteria", label = "Cuckoo", type = "animal", value = 10},
    {id = 14, month = 4, suit = "Wisteria", label = "Ribbon", type = "ribbon", value = 5},
    {id = 15, month = 4, suit = "Wisteria", label = "Wisteria 1", type = "junk", value = 1},
    {id = 16, month = 4, suit = "Wisteria", label = "Wisteria 2", type = "junk", value = 1},

    {id = 17, month = 5, suit = "Iris", label = "Bridge", type = "animal", value = 10},
    {id = 18, month = 5, suit = "Iris", label = "Ribbon", type = "ribbon", value = 5},
    {id = 19, month = 5, suit = "Iris", label = "Iris 1", type = "junk", value = 1},
    {id = 20, month = 5, suit = "Iris", label = "Iris 2", type = "junk", value = 1},

    {id = 21, month = 6, suit = "Peony", label = "Butterflies", type = "animal", value = 10},
    {id = 22, month = 6, suit = "Peony", label = "Ribbon", type = "ribbon", value = 5},
    {id = 23, month = 6, suit = "Peony", label = "Peony 1", type = "junk", value = 1},
    {id = 24, month = 6, suit = "Peony", label = "Peony 2", type = "junk", value = 1},

    {id = 25, month = 7, suit = "Bush Clover", label = "Boar", type = "animal", value = 10},
    {id = 26, month = 7, suit = "Bush Clover", label = "Ribbon", type = "ribbon", value = 5},
    {id = 27, month = 7, suit = "Bush Clover", label = "Clover 1", type = "junk", value = 1},
    {id = 28, month = 7, suit = "Bush Clover", label = "Clover 2", type = "junk", value = 1},

    {id = 29, month = 8, suit = "Pampas", label = "Full Moon", type = "bright", value = 20},
    {id = 30, month = 8, suit = "Pampas", label = "Geese", type = "animal", value = 10},
    {id = 31, month = 8, suit = "Pampas", label = "Pampas 1", type = "junk", value = 1},
    {id = 32, month = 8, suit = "Pampas", label = "Pampas 2", type = "junk", value = 1},

    {id = 33, month = 9, suit = "Chrysanthemum", label = "Sake Cup", type = "animal", value = 10},
    {id = 34, month = 9, suit = "Chrysanthemum", label = "Blue Ribbon", type = "ribbon", value = 5},
    {id = 35, month = 9, suit = "Chrysanthemum", label = "Chrysanthemum 1", type = "junk", value = 1},
    {id = 36, month = 9, suit = "Chrysanthemum", label = "Chrysanthemum 2", type = "junk", value = 1},

    {id = 37, month = 10, suit = "Maple", label = "Deer", type = "animal", value = 10},
    {id = 38, month = 10, suit = "Maple", label = "Blue Ribbon", type = "ribbon", value = 5},
    {id = 39, month = 10, suit = "Maple", label = "Maple 1", type = "junk", value = 1},
    {id = 40, month = 10, suit = "Maple", label = "Maple 2", type = "junk", value = 1},

    {id = 41, month = 11, suit = "Willow", label = "Rain Man", type = "bright", value = 20},
    {id = 42, month = 11, suit = "Willow", label = "Swallow", type = "animal", value = 10},
    {id = 43, month = 11, suit = "Willow", label = "Blue Ribbon", type = "ribbon", value = 5},
    {id = 44, month = 11, suit = "Willow", label = "Lightning", type = "junk", value = 1},

    {id = 45, month = 12, suit = "Paulownia", label = "Phoenix", type = "bright", value = 20},
    {id = 46, month = 12, suit = "Paulownia", label = "Paulownia 1", type = "junk", value = 1},
    {id = 47, month = 12, suit = "Paulownia", label = "Paulownia 2", type = "junk", value = 1},
    {id = 48, month = 12, suit = "Paulownia", label = "Paulownia 3", type = "junk", value = 1},
}

local typeColors = {
    bright = {1, 0.82, 0.29},
    animal = {0.55, 0.79, 0.98},
    ribbon = {0.98, 0.62, 0.73},
    junk = {0.82, 0.82, 0.82}
}

return {
    all = cards,
    typeColors = typeColors
}

