// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {JugadorStruct} from "./JugadorStruct.sol";

// Contrato para los NFTs
// Implementa ERC-721 para representar jugadores
// Permite que el administrador asigne jugadores a los usuarios
// almacena los atributos de cada jugador (nombre,  equipo, puntuaciones, etc.)

contract FantasyPlayerNFT is ERC721, Ownable {
    using JugadorStruct for JugadorStruct.Jugador;

    uint256 public nextTokenId;
    // Mapeo de id de jugador a jugador
    mapping(uint256 => JugadorStruct.Jugador) public jugadores;

    event PlayerMinted(uint256 indexed tokenId, address indexed owner, string name, string team);

    constructor() ERC721("FantasyLeague", "FLNFT") {}

    function mintPlayer(address to, string memory name, string memory team) external onlyOwner {
        require(bytes(name).length > 0, "El nombre del jugador no puede estar vacio");
        require(bytes(team).length > 0, "El nombre del equipo no puede estar vacio");
        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId);
        jugadores[tokenId] = JugadorStruct.Jugador({
            id: tokenId,
            nombre: name,
            equipo: team,
            puntuacion: 0,
            goles: 0,
            asistencias: 0,
            paradas: 0,
            penaltisParados: 0,
            despejes: 0,
            minutosJugados: 0,
            porteriaCero: false,
            tarjetasAmarillas: 0,
            tarjetasRojas: 0,
            ganoPartido: false
        });
        // Emitir un evento para el minting
        emit PlayerMinted(tokenId, to, name, team);
        nextTokenId++;
    }

    function getNextTokenId() external view returns (uint256) {
        return nextTokenId;
    }

    function getPlayer(uint256 _tokenId) external view returns (JugadorStruct.Jugador memory) {
        require(ownerOf(_tokenId) != address(0), "El jugador no existe");
        return jugadores[_tokenId];
    }
}
