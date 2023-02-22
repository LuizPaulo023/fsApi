#' @title Enviar aberturas/transformações para a FS
#' @name post.series
#'
#' @description A função busca enviar as aberturas/transformações solicitadas pelo usuário para a FS
#'
#' @param indicator_code Indicador de 9 dígitos;
#' @param transfs_code Contém a região, agregação, transformação primária e secundária;
#' @param units_pt A unidade de medida de cada série input em Português;
#' @param units_en A unidade de medida de cada série input em Inglês;
#' @param token Token de acesso do usuário.
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @return O retorno é um dataframe com todos os sids criados/enviados para a FS
#'
#' @examples
#' \dontrun{
#' send_transf = fsApi::post.series(indicator_code = "BRBOP0001",
#'                                  region_code = c('AL2', 'GO2'),
#'                                  transfs_code = c("OOML", "OOMM"),
#'                                  units_en = c("teste1", "teste2"),
#'                                  units_pt = c("testea", "testeb")
#'                                  token = headers)
#' }
#'
#' @export


post.series <- function(indicator_code, 
                        region_code,
                        transfs_code,
                        units_en,
                        units_pt,
                        token){

# Guardando inputs

  input <- tidyr::expand_grid(indicador = indicator_code,
                              region = region_code,
                              final = paste0(transfs_code, "_", units_en,"_",units_pt)) %>% 
    rowwise() %>% 
    mutate(transf = str_sub(final, 1,4),
           unit_en = strsplit(final, "_")[[1]][[2]],
           unit_pt = strsplit(final, '_')[[1]][[3]]) %>% 
    ungroup() %>% 
    select(-final)


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
          dplyr::mutate(aggregation = substr(transf, 2, 3),
                        primary_transformation = substr(transf, 1,1),
                        second_transformation = substr(transf, 4,4)) %>%
          dplyr::rowwise() %>%
          dplyr::mutate(body = body,
                 body_json = stringr::str_replace_all(body, c("step_um" = aggregation,
                                                              "step_dois" = region,
                                                              "step_tres" = primary_transformation,
                                                              "step_quatro" = second_transformation,
                                                              "step_cinco" = unit_en,
                                                              "step_seis" = unit_pt)),
                url = paste0("https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/indicators/", indicador, "/series")) %>%
         dplyr::select(indicador,
                       region,
                       transf,
                       body_json,
                       unit_en,
                       unit_pt,
                       url)
  }else{
    print("ERRO: vetor e/ou lista de parâmetros vazios")
}

# Subindo para FS desenvolvimento ------------------------------------------------------------------------------------------------------------

for (i in 1:length(send_fs$indicador)) {
     update_sids = httr::VERB("POST",
                              url = send_fs$url[i],
                              body = send_fs$body_json[i],
                              httr::add_headers(token))

    print(send_fs$indicador[i])
    cat(httr::content(update_sids, 'text'))
    print(send_fs$transf[i])

  }
}


