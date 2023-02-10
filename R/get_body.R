#' @title Estrutura Body da Api
#' @name get.body
#'
#' @description A função retorna o body da api (verbo POST) utilizado na criação de novos indicadores
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @return O retorno é um JSON com o body que precisa ser preenchido para a criação de novos indicadores
#' @examples
#'
#' \dontrun{
#' body_fill = fsApi::get.body()
#' }
#'
#' @export

get.body = function(){

body = '{
  "name": {
    "en-us": "...",
    "pt-br": "..."
  },
  "short_name": {
    "en-us": "...",
    "pt-br": "..."
  },
  "source": {
    "en-us": "...",
    "pt-br": "..."
  },
  "description": {
    "en-us": "...",
    "pt-br": "..."
  },
  "description_full": {
    "en-us": "...",
    "pt-br": "..."
  },
  "unit": "...",
  "country": "...",
  "sector": "...",
  "access_group": "...",
  "is_active": true,
  "tree": [
    {
      "id": "...",
      "node": "...",
      "name": {
        "en-us": "...",
        "pt-br": "..."
      }
    },
    {
      "id": "...",
      "node": "...",
      "name": {
        "en-us": "...",
        "pt-br": "..."
      }
    },
    {
      "id": "...",
      "node": "...",
      "name": {
        "en-us": "...",
        "pt-br": "..."
      }
    },
    {
      "id": "...",
      "node": "...",
      "name": {
        "en-us": "...",
        "pt-br": "..."
      }
    },
    {
      "id": "...",
      "node": "...",
      "name": {
        "en-us": "...",
        "pt-br": "..."
      }
    }
  ]
}';



    return(jsonlite::prettify(body))
}






