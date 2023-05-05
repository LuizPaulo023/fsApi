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

select_sids_to_del <- function(indicator,
                               new_sids,
                               token, 
                               url) {
  
  current_series_raw <- httr::VERB("GET",
                                   url = paste0(url, "api/v1/indicators/", indicator, "/series?limit=2000"),
                                   add_headers(token)) %>% content("parsed")
  
  current_series <- tibble()
  
  for (i in 1:length(current_series_raw[['data']])) {
    sid = current_series_raw[['data']][[i]][['code']]
    
    current_series <- current_series %>%
      bind_rows(tibble(sid = sid))
  }
  
  current_series <- current_series %>%
    pluck('sid')
  
  del_series <- current_series[!(current_series %in% new_sids$sid)]
  
  return(del_series)
}

delete_series <- function(indicator,
                          del_series,
                          token,
                          url){
  
  for (sid in del_series) {
    delete_series <- httr::VERB(
      "DELETE",
      url = paste0(url, "api/v1/indicators/",
                   indicator,
                   "/series/",
                   sid),
      add_headers(token)
    )
    
    cat(httr::content(delete_series, 'text'))
  }
}
