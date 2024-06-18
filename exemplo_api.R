library(plumber)
#library(dplyr)

minha_cotacao_hoje <- function(){
  3.98*(1+0.001)^12
}

# modelo_linear <- randomForest::randomForest(mpg~wt, data = mtcars)
modelo_linear <- lm(mpg~wt, data = mtcars)

#* Escreve uma mensagem
#* @param msg Essa é a mensagem que será retornada pela API
#* @get /echo
function(msg = "Mensagem padrão.") {
  paste0(msg)
}

#* @post /converte_em_dolar
function(reais = 5.21){

  as.numeric(reais)/minha_cotacao_hoje()
}

#* @post /converte_em_reais
function(dolar = 5.21){
  cotacao_dolar <- 3.98
  # esse código poderia ser arbitrariamente complexo

  dolar*minha_cotacao_hoje()
}

#* @post /recupera_previsao
function(peso){
  predict(
    modelo_linear,
    newdata = data.frame(wt = as.numeric(peso))
  )
}

# function(peso){
#   filter(
#     mtcars,
#     wt <= 2
#   ) |>
#     write.csv2() |>
#     capture.output() |>
#     paste0(collapse = "\n")
# }


