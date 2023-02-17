#' @title Enviar aberturas/transformações para a FS
#' @name post.series
#'
#' @description A função busca enviar as aberturas/transformações solicitadas pelo usuário para a FS
#'
#' @param indicator_code Indicador de 9 dígitos;
#' @param transfs_code Contém a região, agregação, transformação primária e secundária;
#' @param units A unidade de medida de cada série input;
#' @param token Token de acesso do usuário.
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @return O retorno é um dataframe com todos os sids criados/enviados para a FS
#'
#' @examples
#' \dontrun{
#' send_transf = fsApi::post.series(indicator_code = "BRBOP0001",
#'                                  transfs_code = c("AL2OOML",
#'                                                   "GO2OOML"),
#'                                  units = c("índice", "índice"),
#'                                  token = headers)
#' }
#'
#' @export


post.series <- function(indicator_code = as.character(),
                        transfs_code = as.character(),
                        units_en = as.character(),
                        units_pt = as.character(),
                        token = as.character()){

# Guardando inputs

  input <- tibble::tibble(transfs = transfs_code,
                          units_en = units_en,
                          units_pt = units_pt) %>%
           dplyr::mutate(indicator = indicator_code)


  if(!is.null(input)){

    body = '{
            "aggregation": "step_um",
            "region": "step_dois",
            "primary_transformation": "step_tres",
            "second_transformation": "step_quatro",
            "unit": {
                     "pt-br": "step_cinco",
                     "en-us": "step_seis"
  }
}';

send_fs = input %>%
          dplyr::mutate(region = base::substr(transfs, 1, 3),
                        aggregation = substr(transfs, 5, 6),
                        primary_transformation = substr(transfs, 4,4),
                        second_transformation = substr(transfs, 7, 7)) %>%
          dplyr::rowwise() %>%
          dplyr::mutate(body = body,
                 body_json = stringr::str_replace_all(body, c("step_um" = aggregation,
                                                              "step_dois" = region,
                                                              "step_tres" = primary_transformation,
                                                              "step_quatro" = second_transformation,
                                                              "step_cinco" = units_en,
                                                              "step_seis" = units_pt)),
                url = paste0("https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/indicators/", indicator, "/series")) %>%
         dplyr::select(indicator,
                 transfs,
                 body_json,
                 units_en,
                 units_pt,
                 url)
  }else{
    print("ERRO: vetor e/ou lista de parâmetros vazios")
}

# Subindo para FS desenvolvimento ------------------------------------------------------------------------------------------------------------

for (i in 1:length(send_fs$indicator)) {
     update_sids = httr::VERB("POST",
                              url = send_fs$url[i],
                              body = send_fs$body_json[i],
                              httr::add_headers(token))

    print(send_fs$indicator[i])
    cat(httr::content(update_sids, 'text'))
    print(send_fs$transfs[i])

  }

  return(send_fs)

}


