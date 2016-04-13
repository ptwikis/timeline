#!/bin/bash

URI="https://pt.wikipedia.org/wiki/Wikipédia:Arqueologia/Linha_do_tempo"
wget $URI
mv Linha_do_tempo linhadotempo


#pega inicio e fim de cada seção
LINHA1=`sed -n '/<h2><span class="mw-headline" id="Geral">/=' linhadotempo` #descobre a linha do padrao
let LINHA1=LINHA1+2

LINHA3=`sed -n '/<h2><span class="mw-headline" id="Combate_ao_vandalismo">/=' linhadotempo` #descobre a linha do padrao
LINHA2=$((LINHA3-2))
let LINHA3=LINHA3+2

LINHA5=`sed -n '/<h2><span class="mw-headline" id="Estatutos">/=' linhadotempo` #descobre a linha do padrao
LINHA4=$((LINHA5-2))
let LINHA5=LINHA5+2

LINHA7=`sed -n '/<h2><span class="mw-headline" id="Constru.C3.A7.C3.A3o_de_artigos">/=' linhadotempo` #descobre a linha do padrao
LINHA6=$((LINHA7-2))
let LINHA7=LINHA7+2

LINHA9=`sed -n '/<h2><span class="mw-headline" id="Comunidade">/=' linhadotempo` #descobre a linha do padrao
LINHA8=$((LINHA9-2))
let LINHA9=LINHA9+2

LINHA10=`sed -n '/<h2><span class="mw-headline" id="Tarefas">/=' linhadotempo` #descobre a linha do padrao
let LINHA10=LINHA10-2

#cria arquivos para cada seção
sed -n "$LINHA1"','"$LINHA2"'p' linhadotempo > geral
sed -n "$LINHA3"','"$LINHA4"'p' linhadotempo > vandalismo
sed -n "$LINHA5"','"$LINHA6"'p' linhadotempo > estatutos
sed -n "$LINHA7"','"$LINHA8"'p' linhadotempo > artigos
sed -n "$LINHA9"','"$LINHA10"'p' linhadotempo > comunidade

##converte as linhas para json
sed -i 's/"/'\''/g' geral vandalismo estatutos artigos comunidade #troca "por '
sed -i 's/^<li>/\t{"date": "/' geral vandalismo estatutos artigos comunidade #muda inicio do arquivo
sed -i 's@</li>$@"}\,@' geral vandalismo estatutos artigos comunidade #muda final do arquivo
sed -i 's@<a href='\''#cite_note@<a href='\''https://pt\.wikipedia\.org/wiki/Wikipédia:Arqueologia/Linha_do_tempo#cite_note@' geral vandalismo estatutos artigos comunidade #muda links referências
sed -i "s@<a href='/wiki/@<a href='https://pt\.wikipedia\.org/wiki/@" geral vandalismo estatutos artigos comunidade #muda links internos
sed -i 's/\([0-9][0-9][0-9][0-9]-[0-9][0-9]\): /\1", "event": "/' geral vandalismo estatutos artigos comunidade #adiciona conteudo após a data


#tira virgula do final da última linha
## por algum motivo a forma antiga de resolver esse problema parou de funcionar para os dois ultimos arquivos!
### mudando... exemplo da solução antiga:
#### TEMP=`tail -n1 geral`
#### sed -i "s@$TEMP@`tail -n1 geral | sed 's/,$//'`@" geral

cat geral | sed '$s/,$//' > geral2
mv geral2 geral
cat vandalismo | sed '$s/,$//' > vandalismo2
mv vandalismo2 vandalismo
cat estatutos | sed '$s/,$//' > estatutos2
mv estatutos2 estatutos
cat artigos | sed '$s/,$//' > artigos2
mv artigos2 artigos
cat comunidade | sed '$s/,$//' > comunidade2
mv comunidade2 comunidade


#faz backup
cp /data/project/ptwikis/ptwikis/static/timeline/data/events.json /data/project/ptwikis/ptwikis/static/timeline/data/events.json.bkp

#monta o json
echo '{' > /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    "geral": [' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
cat geral >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ],' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    "vandalismo":[' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
cat vandalismo >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ],' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    "estatuto":[' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
cat estatutos >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ],' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    "construcao":[' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
cat artigos >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ],' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    "comunidade":[' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
cat comunidade >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '    ]' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json
echo -e '}' >> /data/project/ptwikis/ptwikis/static/timeline/data/events.json


#remove arquivos temporários
rm geral vandalismo estatutos artigos comunidade linhadotempo
