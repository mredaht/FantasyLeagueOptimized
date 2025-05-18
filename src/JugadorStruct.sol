// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library JugadorStruct {
    struct Jugador {
        uint256 id;
        string nombre;
        string equipo;
        uint16 puntuacion;
        uint8 goles;
        uint8 asistencias;
        uint8 paradas;
        uint8 penaltisParados;
        uint8 despejes;
        uint8 minutosJugados;
        bool porteriaCero;
        uint8 tarjetasAmarillas;
        uint8 tarjetasRojas;
        bool ganoPartido;
    }
}
