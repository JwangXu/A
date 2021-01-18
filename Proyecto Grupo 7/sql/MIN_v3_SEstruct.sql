-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-05-2020 a las 22:28:05
-- Versión del servidor: 10.4.11-MariaDB
-- Versión de PHP: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `min`
--
CREATE DATABASE IF NOT EXISTS `min` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `min`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comunidad`
--

CREATE TABLE `comunidad` (
  `ID Comunidad` int(11) NOT NULL,
  `NombreComunidad` varchar(35) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `crimenids`
--

CREATE TABLE `crimenids` (
  `Id` int(11) NOT NULL,
  `IdHecho` int(11) NOT NULL,
  `IdDatos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `criminalidad`
--

CREATE TABLE `criminalidad` (
  `ID Criminalidad` int(11) NOT NULL,
  `TipoDelito` varchar(100) NOT NULL,
  `NumDenuncias` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ipc`
--

CREATE TABLE `ipc` (
  `ID IPC` int(11) NOT NULL,
  `GrupoECOICOP` varchar(100) NOT NULL,
  `Indice` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ipcids`
--

CREATE TABLE `ipcids` (
  `Id` int(11) NOT NULL,
  `idHecho` int(11) NOT NULL,
  `idDatos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preciovivienda`
--

CREATE TABLE `preciovivienda` (
  `ID PrecioVivienda` int(11) NOT NULL,
  `TipoVivienda` varchar(99) NOT NULL,
  `Indice` double NOT NULL,
  `VariacionTrimestral` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temperatura`
--

CREATE TABLE `temperatura` (
  `ID Temperatura` int(11) NOT NULL,
  `TempMedia` double NOT NULL,
  `TempMax` double NOT NULL,
  `TempMin` double NOT NULL,
  `Racha` double NOT NULL,
  `Presion` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiempo`
--

CREATE TABLE `tiempo` (
  `ID Mes` int(11) NOT NULL,
  `Mes` tinyint(4) NOT NULL,
  `Trimestre` tinyint(4) NOT NULL,
  `Anio` smallint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turismo`
--

CREATE TABLE `turismo` (
  `ID Mes` int(11) DEFAULT NULL,
  `ID Comunidad` int(11) DEFAULT NULL,
  `ID IPC` int(11) DEFAULT NULL,
  `ID PrecioVivienda` int(11) DEFAULT NULL,
  `ID Criminalidad` int(11) DEFAULT NULL,
  `ID Temperatura` int(11) DEFAULT NULL,
  `NumTurista` int(11) DEFAULT NULL,
  `deudaPubPIB` double(10,2) DEFAULT NULL,
  `NumParados` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `comunidad`
--
ALTER TABLE `comunidad`
  ADD PRIMARY KEY (`ID Comunidad`),
  ADD UNIQUE KEY `NombreComunidad` (`NombreComunidad`);

--
-- Indices de la tabla `crimenids`
--
ALTER TABLE `crimenids`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `IdHecho` (`IdHecho`),
  ADD KEY `IdDatos` (`IdDatos`);

--
-- Indices de la tabla `criminalidad`
--
ALTER TABLE `criminalidad`
  ADD PRIMARY KEY (`ID Criminalidad`),
  ADD UNIQUE KEY `TipoDelito` (`TipoDelito`,`NumDenuncias`);

--
-- Indices de la tabla `ipc`
--
ALTER TABLE `ipc`
  ADD PRIMARY KEY (`ID IPC`),
  ADD UNIQUE KEY `GrupoECOICOP` (`GrupoECOICOP`,`Indice`);

--
-- Indices de la tabla `ipcids`
--
ALTER TABLE `ipcids`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `idHecho` (`idHecho`),
  ADD KEY `idDatos` (`idDatos`);

--
-- Indices de la tabla `preciovivienda`
--
ALTER TABLE `preciovivienda`
  ADD PRIMARY KEY (`ID PrecioVivienda`),
  ADD UNIQUE KEY `TipoVivienda` (`TipoVivienda`,`Indice`,`VariacionTrimestral`);

--
-- Indices de la tabla `temperatura`
--
ALTER TABLE `temperatura`
  ADD PRIMARY KEY (`ID Temperatura`),
  ADD UNIQUE KEY `TempMedia` (`TempMedia`,`TempMax`,`TempMin`,`Racha`,`Presion`);

--
-- Indices de la tabla `tiempo`
--
ALTER TABLE `tiempo`
  ADD PRIMARY KEY (`ID Mes`),
  ADD UNIQUE KEY `Mes` (`Mes`,`Trimestre`,`Anio`);

--
-- Indices de la tabla `turismo`
--
ALTER TABLE `turismo`
  ADD KEY `ID Mes` (`ID Mes`),
  ADD KEY `ID Comunidad` (`ID Comunidad`),
  ADD KEY `ID PrecioVivienda` (`ID PrecioVivienda`),
  ADD KEY `ID Temperatura` (`ID Temperatura`),
  ADD KEY `ID IPC` (`ID IPC`),
  ADD KEY `ID Criminalidad` (`ID Criminalidad`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `comunidad`
--
ALTER TABLE `comunidad`
  MODIFY `ID Comunidad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `crimenids`
--
ALTER TABLE `crimenids`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `criminalidad`
--
ALTER TABLE `criminalidad`
  MODIFY `ID Criminalidad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ipc`
--
ALTER TABLE `ipc`
  MODIFY `ID IPC` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ipcids`
--
ALTER TABLE `ipcids`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `preciovivienda`
--
ALTER TABLE `preciovivienda`
  MODIFY `ID PrecioVivienda` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `temperatura`
--
ALTER TABLE `temperatura`
  MODIFY `ID Temperatura` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tiempo`
--
ALTER TABLE `tiempo`
  MODIFY `ID Mes` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `crimenids`
--
ALTER TABLE `crimenids`
  ADD CONSTRAINT `crimenids_ibfk_1` FOREIGN KEY (`IdDatos`) REFERENCES `criminalidad` (`ID Criminalidad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `ipcids`
--
ALTER TABLE `ipcids`
  ADD CONSTRAINT `ipcids_ibfk_1` FOREIGN KEY (`idDatos`) REFERENCES `ipc` (`ID IPC`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `turismo`
--
ALTER TABLE `turismo`
  ADD CONSTRAINT `turismo_ibfk_3` FOREIGN KEY (`ID Comunidad`) REFERENCES `comunidad` (`ID Comunidad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `turismo_ibfk_4` FOREIGN KEY (`ID Mes`) REFERENCES `tiempo` (`ID Mes`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `turismo_ibfk_5` FOREIGN KEY (`ID Temperatura`) REFERENCES `temperatura` (`ID Temperatura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `turismo_ibfk_7` FOREIGN KEY (`ID PrecioVivienda`) REFERENCES `preciovivienda` (`ID PrecioVivienda`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `turismo_ibfk_8` FOREIGN KEY (`ID IPC`) REFERENCES `ipcids` (`idHecho`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `turismo_ibfk_9` FOREIGN KEY (`ID Criminalidad`) REFERENCES `crimenids` (`IdHecho`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
