#' @title gen_sids_by_group
#' @name
#'
#' @description
#'
#' @param
#'
#' @author Gabriel Bellé
#'
#' @return
#'
#' @examples
#' \dontrun{
#'
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
    region_code = str_split(region_code, ',')[[1]]
  }

  all_sids <- tidyr::expand_grid(codigo = indicator_code,
                                 region = region_code) %>%
    left_join(indicators_metadado %>%
                select(-c(subgrupo, regioes))) %>%
    left_join(depara_grupos) %>%
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
           sid = paste0(codigo, region, transfs)) %>%
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

