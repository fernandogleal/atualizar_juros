library(plumber)

#* @apiTitle Cálculos Financeiros FGL

#* Informar que o valor será corrigido pelo CDI ou pela SELIC
#* @param valor O valor a ser corrigido.
#* @param dtInicio A data inicial para correção, no formato DD/MM/AAAA
#* @param dtFim A data final para correção. O padrão é a data atual.
#* @param indice O índice a ser utilizado para correção. Atualmente, pode ser "CDI" ou "SELIC"
#* @get /corrigir_taxas_juros

function(valor = 1000, dtInicio = "01/01/2024", dtFim = Sys.Date(), indice = "cdi"){
  indice <- tolower(indice)
  valor <- as.numeric(valor)

  ajustar_data <- function(database){
    if(nchar(database) != 7 & substr(database, 3, 3) != "/") stop("'inicio' tem que estar no formato DD/MM/YYYY.")
    lubridate::dmy(database)
  }

  # Map of indices to URLs
  indice_urls <- c("cdi" = "http://ipeadata.gov.br/api/odata4/ValoresSerie(SERCODIGO='SGS366_CDI366')",
                   "selic" = "http://ipeadata.gov.br/api/odata4/ValoresSerie(SERCODIGO='GM366_TJOVER366')")

  # Get price indice
  message("\nDownloading os dados do IPEA data API\n...\n")
  dados <- httr::GET(indice_urls[indice])
  httr::stop_for_status(dados, task = paste("Buscando os dados do", indice, "da API do IPEA."))

  # Calculate changes in prices
  dados <- httr::content(dados)[[2]]
  dados <- dplyr::bind_rows(dados)[,2:3]
  dados$VALDATA <- lubridate::as_date(dados$VALDATA)
  dados <- dados |>
    dplyr::select(Data := 1, IndiceDiario:= 2) |>
    dplyr::filter(!is.na(IndiceDiario)) |>
    dplyr::mutate(Indice = indice,
           FatorDiario = dplyr::if_else(Indice == "cdi", (1+IndiceDiario/100),
                                  dplyr::if_else(Indice == "selic", (1+IndiceDiario/100)^(1/252), NA_real_))) |>
    dplyr::select(-IndiceDiario)

  # Parâmetros --------------------------------------------------------------
  ## Data inicial
  dtInicio <- ajustar_data(dtInicio)
  dtInicio <- dados$Data[which.max(dados$Data[dados$Data <= dtInicio])]

  if(!lubridate::is.Date(dtFim)){
    dtFim <- ajustar_data(dtFim)
  }

  dtFim <- dados$Data[which.max(dados$Data[dados$Data <= dtFim])]

  # CDI no período ----------------------------------------------------------
  df <- dados |>
    dplyr::filter(Data >= dtInicio & Data <= dtFim) |>
    dplyr::mutate(FatorAcum = cumprod(FatorDiario),
                  IndiceAnualizado = ((FatorDiario)^252-1)*100,
                  ValorAtualizado = valor*FatorAcum)|>
    tail(1)

valor <- formatC(valor, format = "f", digits = 2, big.mark = ".", decimal.mark = ",")
valor_corrigido <- formatC(round(df$ValorAtualizado,2), format = "f", digits = 2, big.mark = ".", decimal.mark = ",")

print(glue::glue("R$ {valor}, após correção pelo índice {toupper(indice)} no intervalo de {format(dtInicio, '%d/%m/%Y')} a {format(dtFim, '%d/%m/%Y')}, resultou no valor atualizado de R$ {valor_corrigido}."))

}

#* Recebendo 3 números, será calculada a média simples entre eles.
#* @param a Primeiro número;
#* @param b Segundo número;
#* @param c Terceiro número;
#* @get /media_tres_numeros

media_tres_numeros <- function(a, b, c) {

  a <- as.numeric(a)
  b <- as.numeric(b)
  c <- as.numeric(c)

  media <- (a + b + c) / 3

    return(media)
  }





