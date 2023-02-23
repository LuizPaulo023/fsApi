#' @title Deletando aberturas/transformações para a FS
#' @name delete_series
#'
#' @description
#'
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @return
#'
#' @examples
#' \dontrun{
#' }
#'
#' @export

delete_series <- function(indicator = as.character(),
                          token = as.character()){

  series_raw <- httr::VERB("GET", url = "https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/series?limit=2000",
                           add_headers(token_homo)) %>% content("parsed")

     df_fill <- data.frame(code = character(),
                           indicator_code = character(),
                           stringsAsFactors = F)

    for (i in 1:length(series_raw[["data"]])) {
      code <- series_raw[["data"]][[i]][["code"]]
      indicator_code <- series_raw[["data"]][[i]][["indicator_code"]]

      df_fill <- rbind(df_fill,
                       data.frame(code = code,
                                  indicator_code = indicator_code,
                                  stringsAsFactors = F))
  }


series_fs <- df_fill %>%
             dplyr::filter(indicator_code == indicator)


for (i in 1:nrow(series_fs)) {

  delete_series <- httr::VERB("DELETE",
                              url = paste0("https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/indicators/", series_fs$indicator_code[i], "/series/", series_fs$code[i]),
                              add_headers(token_homo))

  cat(httr::content(delete_series, 'text'))


  }

}


