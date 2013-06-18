|-----------------------------------------------------------------------------------------------------------------------------------------------------|
|               #########################            Identificación ficheiros resultado da execución.            #########################            |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
|       Ficheiros                                                   |                                  Explicación                                    |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/error/erros.tmp                                           | Existe se o script usado para atopar as súas dependencias ten erros de sintaxe. |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/main/chamada-funcions.tmp                                 | Funcións do main: As executadas fora das funcións e que chaman ás demais.       |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/depends/dependencia-un-nivel_[name-funcion].tmp           | Primer nivel de dependencias de cada función.                                   |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/depends/dependencia-un-nivel.tmp                          | Primer nivel de dependencias de tódalas funcións.                               |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/depends/dependencias-funcions.tmp                         | Tódalas dependencias das funcións durante a execución do script.                |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/debug/depuracion.tmp                                      | Existe se hai funcións que non son chamadas durante a execución.                |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/diagrams/diagrama-[number]*.svg                           |                                                                                 |
|                                                                   | Diagramas das dependencias entre funcións.                                      |
| reports/diagrams/diagrama-dependencias-funcions_[number]*.dot     |                                                                                 |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/diagrams/diagrama-global.svg                              |                                                                                 |
| reports/diagrams/diagrama-global-simplificado.svg                 | Diagramas Global das dependencias entre as funcións.                            |
| reports/diagrams/diagrama-dependencias-funcions.dot               |                                                                                 |
| reports/diagrams/diagrama-dependencias-funcions-simplificada.dot  |                                                                                 |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/functions/funcions_[name-function].tmp                    | O código de cada función nun ficheiro.                                          |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/functions/funcions.tmp                                    | O código de tódalas funcións nun ficheiro.                                      |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
|                                                                   | Ficheiros que conteñen as liñas do script que non pertencen a ningunha función: |
| reports/out-functions/without-number.tmp                          |   Sen numerar e sen ter en conta as liñas en branco.                            |
| reports/out-functions/with-number.tmp                             |   Numeradas e tendo en contas as liñas en branco.                               |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| reports/debug/nodes_only.tmp                                      | Existe se se atopan funcións que non chaman a outras.                           |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|
