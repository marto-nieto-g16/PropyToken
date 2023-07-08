# PropyToken
# AssetProxy Contract

El contrato AssetProxy es un contrato de proxy que implementa la interfaz ERC20 y actúa como una puerta de enlace para un solo activo EToken2. Este contrato añade el símbolo de EToken2 y el llamante (sender) al reenviar las solicitudes a EToken2. Cada solicitud realizada por el llamante se envía primero a la implementación específica del activo, que luego llama al contrato de proxy para reenviarlo a EToken2.

## Correcciones Realizadas

Se han realizado las siguientes correcciones en el código del contrato:

- Se han actualizado todas las funciones para que sean compatibles con la versión de compilador `0.8.0` de Solidity.
- Se ha añadido el modificador `memory` a los parámetros de cadena de texto (string) en las funciones para especificar que los datos se almacenen en la memoria en lugar de en el almacenamiento.
- Se ha actualizado el modificador `constant` por el modificador `view` en las funciones que no modifican el estado del contrato.
- Se ha reemplazado el modificador `throw` por `revert` en la función `_performGeneric` para lanzar una excepción y revertir los cambios en caso de error.
- Se han actualizado los eventos `Transfer` y `Approval` para que sean compatibles con la versión `0.8.0` de Solidity.
- Se han corregido los modificadores `onlyEToken2` y `onlyAssetOwner` para utilizar la estructura `modifier` correctamente.
- Se ha añadido el modificador `payable` a la función `fallback` para permitir que el contrato reciba ethers.
- Se ha actualizado el control de acceso a la función `receiveEthers` para permitir que solo sea llamada por el contrato EToken2 asignado.
- Se ha actualizado la función `getVersionFor` para verificar si el símbolo del EToken2 está bloqueado antes de determinar la versión del contrato.

## Uso

El contrato AssetProxy se utiliza como un proxy para un activo específico de EToken2. Para utilizarlo, sigue los siguientes pasos:

1. Despliega el contrato AssetProxy en la red Ethereum.
2. Llama a la función `init` para asignar la dirección del contrato EToken2, el símbolo y el nombre del activo.
3. Interactúa con el contrato AssetProxy utilizando las funciones de la interfaz ERC20.

## Contribuciones

Las contribuciones son bienvenidas. Si encuentras algún problema o tienes alguna mejora, por favor, abre un issue o envía un pull request.

## Licencia

Este contrato está sujeto al Acuerdo de Licencia de Ambisafe. No se permite su uso o distribución sin permiso por escrito de Ambisafe. Puedes encontrar el acuerdo de licencia en [este enlace](https://www.ambisafe.co/terms-of-use/).
