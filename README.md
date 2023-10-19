# Bodyfit

Bodyfit se trata de uma aplicação para informatização da academia. Sua base está no cadastro de treinos e fichas de exercícios para uso dos clientes de forma que eles possam acompanhar digitalmente todo o seu histórico de treino em qualquer dispositivo eletrônico de desejo como celular, tablet e notebook.

## 🚀 Começando

Essas instruções permitirão que você obtenha uma cópia do projeto em operação na sua máquina local para fins de desenvolvimento e teste.

### 📋 Pré-requisitos

* O projeto foi desenvolvido no *Delphi 10.4 Community Edition*, logo será necessário que se tenha uma versão igual ou superior com compatibilidade instalada.
* Para a instalação das dependências do projeto é necessário que se tenha a ferramenta [Boss](https://github.com/HashLoad/boss) devidamente instalada e pronta para uso.
* Todas as dependências utilizadas estão detalhadas na seção [Construído com](#%EF%B8%8F-construído-com).
* A aplicação servidor utiliza o banco de dados *Firebird 4.0* ao qual foi criado através do *IBExpert Personal Edition Version 2023.9.13.1*.
* A aplicação cliente utiliza o banco de dados *SQLite* ao qual é criado automaticamente pela aplicação e pode ser acessado via *SQLiteStudio v3.4.4*.

### 🔧 Instalação

Passo 1: Clonar o projeto para o diretório `C:\Bodyfit` através do comando abaixo:

```
git clone https://github.com/pmbfsa/Bodyfit
```

Passo 2: Acessar o diretório `C:\Bodyfit\Mobile` e instalar as seguintes dependências:

* dataset-serialize
* restrequest4delphi

Passo 3: Acessar o diretório `C:\Bodyfit\ServidorHorse` e instalar as seguintes dependências:

* dataset-serialize
* horse
* horse-basic-auth
* horse-cors
* jhonson

## ⚙️ Executando

O projeto se baseia em dois executáveis:

### Servidor

Responsável por guardar as informações de usuário e os dados permanentes do projeto. Com todas as dependências devidamente instaladas basta realizar o *build*, *compile* e *run* que uma pequena janela branca aparecerá informando que o servidor está em execução informando o IP e a Porta.

Por padrão a aplicação utiliza o IP localhost e a Porta 3050, mas todos os dados de conexão com o arquivo de banco de dados pode ser alterado conforme a necessidade em `C:\Bodyfit\ServidorHorse\Win32\Debug\Servidor.ini`.

### Mobile

Responsável pela GUI da aplicação. Será executado no aparelho do usuário que de forma automatizada irá se conectar com o servidor e realizar todos os consumos necessários para armazenamento e controle dos dados do usuário.

O servidor possuí um banco de dados com as informações permanentes, contudo o dispositivo do usuário utiliza um banco de dados portátil e mais simples para armazenamento e manipulação de informações temporárias.

Com todas as dependências devidamente instaladas basta realizar o *build*, *compile* e *run* que a tela principal da aplicação será apresentada pronta para uso.

**ATENÇÃO: Para teste inicial é interessante que a aplicação cliente seja executada no mesmo dispositivo que o servidor.**

## 🛠️ Construído com

* [dataset-serialize](https://github.com/viniciussanchez/dataset-serialize) - Biblioteca que simplifica a interação entre JSON e DataSet.
* [restrequest4delphi](https://github.com/viniciussanchez/RESTRequest4Delphi) - API para consumo de serviços REST.
* [horse](https://github.com/HashLoad/horse) - Web Framework para Delphi inspirado no [Express](https://github.com/expressjs/express).
* [horse-basic-auth](https://github.com/HashLoad/horse-basic-auth) - Middleware utilizado pelo HORSE para trabalhar com atenticação básica.
* [horse-cors](https://github.com/HashLoad/horse-cors) - Middleware utilizado pelo HORSE para lidar com CORS em APIs.
* [jhonson](https://github.com/HashLoad/jhonson) - Middleware utilizado pelo HORSE para trabalhar com JSON.

## ✒️ Autores

* **Professor** - *Criação* - [Heber Stein Mazutti](https://br.linkedin.com/in/heber-stein-mazutti-20292922)
* **Estudante** - *Desenvolviemnto e Documentação* - [Paulo Márcio](https://github.com/pmbfsa)

## 📄 Licença

Este projeto está sob a licença GNU General Public License v3.0 - veja o arquivo [LICENSE](https://github.com/pmbfsa/Bodyfit/blob/main/LICENSE) para detalhes.

## 🎁 Agradecimento

Agradeço ao professor Heber Stein por todo o conhecimento compartilhado no seu curso Mobile 360.
