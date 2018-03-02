pragma solidity ^0.4.15;

import "./SafeMath.sol";

contract Quini6 {

	using SafeMath for uint256;

	event NuevaJugada(address jugador, uint256 valor, uint256 numJugadas, uint[6] jugada);
	event Bolillero(uint[6] bolillas);

	//valido que:
	/*
		- estén entre el 0 y el 45
		- no sean repetidos
		- sean seis numeros:
			* si la jugada viene con 5 numeros, el sexto se auto setea en 0
			* si la jugada viene con menos de 5 numeros, al setearse 0 para los numeros que faltan
			  la validación falla por números duplicados
	*/
	modifier validarJugada(uint[6] jugada) {
		bool esInvalido = false;
		bool esDuplicado = false;
		uint[6] memory jugarreta = [uint256(46), uint256(46), uint256(46), uint256(46), uint256(46), uint256(46)];
		for (uint i = 0; i < 6; i++) {
			if (jugada[i] < 0 || jugada[i] > 45) {
				esInvalido = true;
				break;
			}
			if (i == 0) {
				jugarreta[i] = jugada[i];
			} else {
				for (uint j = 0; j < 6; j++) {
					if (jugarreta[j] == jugada[i]) {
						esInvalido = true;
						esDuplicado = true;
						break;
					}
				}
				jugarreta[i] = jugada[i];
				if (esDuplicado) {
					break;
				}
			}
		}

		require(!esInvalido);
		_;
	}

	modifier validarPago() {
		//valido que el pago sea exactamente de 0.003 sin considerar el gasto de gas
		require(msg.value == .003 ether);
		_;
	}	

	struct Jugador {
		address addr;
		uint[6][] jugadas;       
	}

	mapping(address => bool) jugadorExistente;
	mapping(address => uint256) mapaJugadores;
	Jugador[] jugadores;

	// TENGO QUE MANDAR TODO EL PROCESAMIENTO DE PAGO AL GANADOR DEL BOLETO EN CASO QUE HAYA

	function jugar(uint[6] _jugada) public payable validarJugada(_jugada) validarPago {

		if (!jugadorExistente[msg.sender]) {
			Jugador memory jugador = Jugador(msg.sender, new uint[6][](0));
			jugadores.push(jugador);
			jugadorExistente[msg.sender] = true;
			mapaJugadores[msg.sender] = jugadores.length - 1;
		}
		
		jugadores[mapaJugadores[msg.sender]].jugadas.push(_jugada);

		NuevaJugada(msg.sender, msg.value, jugadores[mapaJugadores[msg.sender]].jugadas.length, _jugada);
	}

	function getNumeroJugadores() view public returns(uint) {
		return jugadores.length;
	}

	// EVM es deterministica, por lo que los numeros randoms se calculan en relacion a los blocknumers
	function random(uint _index) private view returns (uint256) {
		return uint256(block.blockhash(block.number - _index * 2));
	}

	// TODO: tengo que corroborar que los numeros no sean repetidos
	// TODO: hacer solución con oraculo
	function bolillero() public payable {
		uint[6] memory bolillas;
		for (uint i = 1; i <= 6; i++) {
			uint numero = random(i) % 45;
			bolillas[i-1] = numero;
		}
		Bolillero(bolillas);
	}

	/*
	function getRoomPlayers(uint i) public view returns (address[]){
		return rooms[i].players;
	}

	function getJugadores() view public returns(address[]) {
		return jugadores;
	}

	function getJugador(address _address) view public returns (uint[6]) {
		return boleta[_address];
	}

	function countJugadores() view public returns (uint) {
		return jugadores.length;
	}*/
	
}