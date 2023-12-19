base::rm(list = ls())

library(tidyverse)

user = base::getwd() %>%
  stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/curadoria/'
setwd(paste0(user,path))


# fundos novos ------------------------------------------------------------
# Fundos Faltantes - planilha atualizada dia 11/12/2023

novos <- readxl::read_excel(paste0(user, path,
                                   'anbima/fundos_faltantes.xlsx')) %>%
         janitor::clean_names() %>%
         dplyr::filter(!is.na(nome_fantasia)) %>%
         filter(!is.na(codigo_fundo))

# Fundos atuais - planilha atualizada dia 12/12/2023 ----------------------

atuais <- readxl::read_excel(paste0(user, path,
                                    'anbima/fundos_anbima.xlsx')) %>%
          dplyr::rename(Indicador = indicator_code)

seq_ind <- readxl::read_excel(paste0(user, path,
                                     'anbima/seq_ind_anb.xlsx')) %>%
  mutate(final_sequence = paste0('BRANB', final_sequence))

use_ind <- seq_ind$final_sequence[!(seq_ind$final_sequence %in% atuais$Indicador)] %>% tibble()

# Metadados ====================================================================
# Se a data de registro atual for igual NA, retorna data atual

metadados <- novos %>%
  mutate(name_pt_fs = paste0(nome_fantasia, ' (', codigo_fundo, ')'),
         name_en_fs = name_pt_fs,
         name_abv_pt_fs = name_pt_fs,
         name_abv_en_fs = name_pt_fs,
         regioes = '000',
         projecao = NA,
         premium = 'premium',
         pais = 'BR',
         setor_fs = 'ANB',
         ranking = 1,
         tree_en_fs = 'Brazil, Testes Anbima',
         tree_pt_fs = 'Brasil, Testes Anbima',
         fonte_fs_en = 'Anbima',
         fonte_fs_pt = 'Anbima',
         tamanho = data_registro_atual - data_inicio,
         tamanho = ifelse(is.na(tamanho),
                          as.POSIXct(Sys.Date(), format = '%y-%m-%d') - data_inicio,
                          tamanho),
         tamanho = as.numeric(tamanho),
         description_pt_fs = paste('O indicador é referente ao fundo',
                                  nome_fantasia,
                                  'da classe anbima',
                                  dados_cadastrais_tipo_anbima,
                                  '. Apresenta as informações sobre rentabilidade, valor da cota, patrimônio líquido, número de cotistas, resgate, captação e captação líquida.'
                                  ),
         description_en_fs = paste('The indicator refers to the',
                                  nome_fantasia,
                                  'fund, of the anbima',
                                  dados_cadastrais_tipo_anbima,
                                  'class. It shows information on return, share value, net equity, number of shareholders, redemption, funding and net funding.'),
         link_metodologia_fs_pt = 'Veja mais informações sobre o indicador diretamente na fonte por meio do seguinte site: https://data.anbima.com.br/fundos',
         link_metodologia_fs_en = 'You can find more information about the indicator directly from the source through the following website: https://data.anbima.com.br/fundos'
         )

# %>%
#   select(name_pt_fs:link_metodologia_fs_en)

# Filtrando e organizando ======================================================
# ATENCAO: Não SUBIR fundos menos de 33 dias de periodidade \\\\\\\\\\\\\\\\\\\\

metadados = metadados %>%
            dplyr::filter(tamanho > 33) %>%
                   rename(frequencia = movimentacao_divulgacao_cota) %>%
                   mutate(frequencia = case_when(frequencia == 'DIARIA' ~ 'D',
                                                 frequencia == 'MENSAL' ~ 'M',
                                                 frequencia == 'ANUAL' ~ 'Y'))


# Filtragem de acordo com os fundos já existentes

trunc_ind <- use_ind %>%
  head(nrow(metadados))

metadados_out <- metadados %>%
                 dplyr::mutate(indicator_code = trunc_ind$.) %>%
                 relocate(indicator_code, .before = name_pt_fs)

writexl::write_xlsx(metadados_out, paste0(user, path,
                                          'anbima/novos_indicadores.xlsx'))


