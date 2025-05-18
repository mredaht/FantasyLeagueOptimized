// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SavePlayers {
    struct PlayerData {
        string name;
        string team;
    }

    function getPlayers() external pure returns (PlayerData[] memory) {
        PlayerData[] memory players = new PlayerData[](133); // Adjust size as needed
        uint256 index = 0;
        // Barcelona
        players[index] = PlayerData("Lewandowski", "Barcelona");
        players[index++] = PlayerData("Pedri", "Barcelona");
        players[index++] = PlayerData("Bellingham", "Real Madrid");
        players[index++] = PlayerData("Vinicius", "Real Madrid");

        players[index++] = PlayerData("Gavi", "Barcelona");
        players[index++] = PlayerData("Ter Stegen", "Barcelona");
        players[index++] = PlayerData("De Jong", "Barcelona");
        players[index++] = PlayerData("Araujo", "Barcelona");
        players[index++] = PlayerData("Raphinha", "Barcelona");
        players[index++] = PlayerData("Cubarsi", "Barcelona");
        players[index++] = PlayerData("Kounde", "Barcelona");
        players[index++] = PlayerData("Lamine Yamal", "Barcelona");
        players[index++] = PlayerData("Balde", "Barcelona");

        // Real Madrid
        players[index++] = PlayerData("Rodrygo", "Real Madrid");
        players[index++] = PlayerData("Mbappe", "Real Madrid");
        players[index++] = PlayerData("Modric", "Real Madrid");
        players[index++] = PlayerData("Courtois", "Real Madrid");
        players[index++] = PlayerData("Tchouameni", "Real Madrid");
        players[index++] = PlayerData("Rudiger", "Real Madrid");
        players[index++] = PlayerData("Valverde", "Real Madrid");
        players[index++] = PlayerData("Mendy", "Real Madrid");
        players[index++] = PlayerData("Alaba", "Real Madrid");

        // Atletico Madrid
        players[index++] = PlayerData("Griezmann", "Atletico Madrid");
        players[index++] = PlayerData("Julian Alvarez", "Atletico Madrid");
        players[index++] = PlayerData("Barrios", "Atletico Madrid");
        players[index++] = PlayerData("Oblak", "Atletico Madrid");
        players[index++] = PlayerData("Lenglet", "Atletico Madrid");
        players[index++] = PlayerData("Gimenez", "Atletico Madrid");
        players[index++] = PlayerData("Llorente", "Atletico Madrid");
        players[index++] = PlayerData("De Paul", "Atletico Madrid");
        players[index++] = PlayerData("Giuliano", "Atletico Madrid");
        players[index++] = PlayerData("Samuel Lino", "Atletico Madrid");
        players[index++] = PlayerData("Le Normand", "Atletico Madrid");

        // Athletic Bilbao
        players[index++] = PlayerData("Nico Williams", "Athletic Bilbao");
        players[index++] = PlayerData("Unai Simon", "Athletic Bilbao");
        players[index++] = PlayerData("Vivian", "Athletic Bilbao");
        players[index++] = PlayerData("Yuri", "Athletic Bilbao");
        players[index++] = PlayerData("Inaki Williams", "Athletic Bilbao");
        players[index++] = PlayerData("Sancet", "Athletic Bilbao");

        //VillaReal
        players[index++] = PlayerData("Gueye", "Villareal");
        players[index++] = PlayerData("Diego Conde", "Villareal");
        players[index++] = PlayerData("Sergi Cardona", "Villareal");
        players[index++] = PlayerData("Foyth", "Villareal");
        players[index++] = PlayerData("Alex Baena", "Villareal");
        players[index++] = PlayerData("Ayoze Perez", "Villareal");

        //Rayo Vallecano
        players[index++] = PlayerData("Batalla", "Rayo Vallecano");
        players[index++] = PlayerData("Ratiu", "Rayo Vallecano");
        players[index++] = PlayerData("Isi Palazon", "Rayo Vallecano");
        players[index++] = PlayerData("Lejeune", "Rayo Vallecano");
        players[index++] = PlayerData("De Frutos", "Rayo Vallecano");

        // Betis
        players[index++] = PlayerData("Adrian", "Betis");
        players[index++] = PlayerData("Llorente", "Betis");
        players[index++] = PlayerData("Isco", "Betis");
        players[index++] = PlayerData("Anthony", "Betis");
        players[index++] = PlayerData("Abde", "Betis");

        // Mallorca
        players[index++] = PlayerData("Greif", "Mallorca");
        players[index++] = PlayerData("Maffeo", "Mallorca");
        players[index++] = PlayerData("Mojica", "Mallorca");
        players[index++] = PlayerData("Dani Rodriguez", "Mallorca");
        players[index++] = PlayerData("Muriqi", "Mallorca");
        players[index++] = PlayerData("Darder", "Mallorca");

        //Real Sociedad
        players[index++] = PlayerData("Remiro", "Real Sociedad");
        players[index++] = PlayerData("Aguerd", "Real Sociedad");
        players[index++] = PlayerData("Sucic", "Real Sociedad");
        players[index++] = PlayerData("Zubimendi", "Real Sociedad");
        players[index++] = PlayerData("Sergio Gomez", "Real Sociedad");
        players[index++] = PlayerData("Oyarzabal", "Real Sociedad");
        players[index++] = PlayerData("Kubo", "Real Sociedad");

        // Celta
        players[index++] = PlayerData("Guaita", "Celta");
        players[index++] = PlayerData("Starfelt", "Celta");
        players[index++] = PlayerData("Marcos Alonso", "Celta");
        players[index++] = PlayerData("Mingueza", "Celta");
        players[index++] = PlayerData("Aspas", "Celta");

        // Sevilla
        players[index++] = PlayerData("Nyland", "Sevilla");
        players[index++] = PlayerData("Saul", "Sevilla");
        players[index++] = PlayerData("Bade", "Sevilla");
        players[index++] = PlayerData("Lukebakio", "Sevilla");
        players[index++] = PlayerData("Ruben Vargas", "Sevilla");
        players[index++] = PlayerData("Isaac", "Sevilla");

        // Girona
        players[index++] = PlayerData("Gazzaniga", "Girona");
        players[index++] = PlayerData("Miguel Gutierrez", "Girona");
        players[index++] = PlayerData("Blind", "Girona");
        players[index++] = PlayerData("Tsygankov", "Girona");
        players[index++] = PlayerData("Bryan Gil", "Girona");
        players[index++] = PlayerData("Danjuma", "Girona");

        // Osasuna
        players[index++] = PlayerData("Sergio Herrera", "Osasuna");
        players[index++] = PlayerData("Catena", "Osasuna");
        players[index++] = PlayerData("Bryan", "Osasuna");
        players[index++] = PlayerData("Budimir", "Osasuna");
        players[index++] = PlayerData("Ruben Garcia", "Osasuna");
        players[index++] = PlayerData("Aimar Oroz", "Osasuna");

        // Getafe
        players[index++] = PlayerData("David Soria", "Getafe");
        players[index++] = PlayerData("Alderete", "Getafe");
        players[index++] = PlayerData("Djene", "Getafe");
        players[index++] = PlayerData("Arrambari", "Getafe");
        players[index++] = PlayerData("Mayoral", "Getafe");
        players[index++] = PlayerData("Terrats", "Getafe");

        // Espanyol
        players[index++] = PlayerData("Joan Garcia", "Espanyol");
        players[index++] = PlayerData("Omar El Hilali", "Espanyol");
        players[index++] = PlayerData("Kumbulla", "Espanyol");
        players[index++] = PlayerData("Jofre", "Espanyol");
        players[index++] = PlayerData("Puado", "Espanyol");
        players[index++] = PlayerData("Roberto", "Espanyol");

        // Las Palmas
        players[index++] = PlayerData("Cillessen", "Las Palmas");
        players[index++] = PlayerData("Mckenna", "Las Palmas");
        players[index++] = PlayerData("Essugo", "Las Palmas");
        players[index++] = PlayerData("Sandro", "Las Palmas");
        players[index++] = PlayerData("Moleiro", "Las Palmas");
        players[index++] = PlayerData("Fabio Silva", "Las Palmas");

        //Leganes
        players[index++] = PlayerData("Dimitrovic", "Leganes");
        players[index++] = PlayerData("Juan Cruz", "Leganes");
        players[index++] = PlayerData("Rosier", "Leganes");
        players[index++] = PlayerData("Dani Raba", "Leganes");
        players[index++] = PlayerData("Nastacic", "Leganes");

        // Alaves
        players[index++] = PlayerData("Sivera", "Alaves");
        players[index++] = PlayerData("Tenaglia", "Alaves");
        players[index++] = PlayerData("Joan Jordan", "Alaves");
        players[index++] = PlayerData("Carlos Vicente", "Alaves");
        players[index++] = PlayerData("Kike Garcia", "Alaves");
        players[index++] = PlayerData("Toni Martinez", "Alaves");

        // Valencia
        players[index++] = PlayerData("Mamardashvilli", "Valencia");
        players[index++] = PlayerData("Mosquera", "Valencia");
        players[index++] = PlayerData("Guerra", "Valencia");
        players[index++] = PlayerData("Rioja", "Valencia");
        players[index++] = PlayerData("Gaya", "Valencia");
        players[index++] = PlayerData("Sadiq", "Valencia");

        // Valladolid
        players[index++] = PlayerData("Karl Hein", "Valladolid");
        players[index++] = PlayerData("Moro", "Valladolid");
        players[index++] = PlayerData("Marcos Andre", "Valladolid");
        players[index++] = PlayerData("Amallah", "Valladolid");
        players[index++] = PlayerData("Sylla", "Valladolid");

        return players;
    }
}
