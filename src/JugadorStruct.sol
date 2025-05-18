// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library JugadorStruct {
    struct Jugador {
        uint256 id; // Identificador único del jugador
        string nombre;
        string equipo;
        uint256 puntuacion; //Puntuacion total del jugador
        // Nuevos campos para registrar estadísticas
        uint256 goles;
        uint256 asistencias;
        uint256 paradas;
        uint256 penaltisParados;
        uint256 despejes;
        uint256 minutosJugados;
        bool porteriaCero;
        uint256 tarjetasAmarillas;
        uint256 tarjetasRojas;
        bool ganoPartido;
    }
}
