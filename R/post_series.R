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
#' send_transf = fsApi::post.series()
#' }
#'
#' @export

gen_sids_by_group <- function(indicators_metadado,
                              depara_grupos,
                              depara_unidade) {

  indicators_full <- indicators_metadado %>%
    left_join(depara_grupos)

  region_code <- indicators_metadado$regioes %>%
    unique()

  indicator_code = indicators_metadado$indicator_code %>%
    unique()

  if(region_code != '000') {
    region_code = str_replace_all(region_code, ' ', '')
    region_code = str_replace_all(region_code, "[\r\n]" , "")
    region_code = str_split(region_code, ',')[[1]]
  }

  all_sids <- tidyr::expand_grid(indicator_code = indicator_code,
                                 region = region_code) %>%
    left_join(indicators_metadado %>%
                select(-c(regioes))) %>%
    left_join(depara_grupos, relationship = 'many-to-many') %>%
    mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1),
                              str_sub(transfs, 4,4))) %>%
    left_join(depara_unidade %>%
                select(cod1_cod2, un_pt, un_en)) %>%
    rowwise() %>%
    mutate(un_pt = ifelse(is.na(un_pt),
                          ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                          un_pt),
           un_en = ifelse(is.na(un_en),
                          ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                          un_en),
           sid = paste0(indicator_code, region, transfs)) %>%
    ungroup() %>%
    select(c(sid, un_pt, un_en))

  if(any(is.na(all_sids$un_pt)) | any(is.na(all_sids$un_en))) {
    na_un <- all_sids %>%
      filter(is.na(un_pt) | is.na(un_en)) %>%
      distinct(sid) %>%
      pluck('sid')

    all_sids <- all_sids %>%
      mutate(un_pt = 'teste',
             un_en = 'test')

    warning(paste0('Os seguintes indicadores não possuem unidade de medida preenchida: ', paste(na_un, collapse = ', ')))
  }

  return(all_sids)
}

post_series <- function(indicators_metadado, token, url){

  body = '{
            "aggregation": "step_um",
            "region": "step_dois",
            "primary_transformation": "step_tres",
            "second_transformation": "step_quatro",
            "unit": {
              "pt-br": "step_cinco",
              "en-us": "step_seis"}
            }';

  send_fs = indicators_metadado %>%
    dplyr::mutate(indicador = substr(sid, 1,9),
                  region = substr(sid, 10,12),
                  aggregation = substr(sid, 14, 15),
                  transf_1 = substr(sid, 13,13),
                  transf_2 = substr(sid, 16,16)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(body = body,
                  body_json = stringr::str_replace_all(body, c("step_um" = aggregation,
                                                               "step_dois" = region,
                                                               "step_tres" = transf_1,
                                                               "step_quatro" = transf_2,
                                                               "step_cinco" = un_pt,
                                                               "step_seis" = un_en)),
                  url = paste0(url, 'api/v1/indicators/', indicador, "/series"))

  result = tibble(out = c())

  for (series in unique(send_fs$sid)) {
    sending_sid <- send_fs %>%
      filter(sid == series)

    update_sids = httr::VERB("POST",
                             url = sending_sid$url,
                             body = sending_sid$body_json,
                             httr::add_headers(token))

    cat(httr::content(update_sids, 'text'))

    result <- result %>%
      bind_rows(tibble(out = update_sids$status_code))
  }

  if(any(!(result$out %in% c(200)))) {
    stop('problema no envio')
  }

}



