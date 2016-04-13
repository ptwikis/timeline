#!/bin/bash

#incrementando arquivo com lista de meses
MES=`date -d "-1 month" +%b-%Y`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months_temp
sed "/date/{p;s/.*/$MES/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months_temp
#fim lista meses

#gerar dados do mes

##definido variaveis
ANOMESATUAL=`date +%Y%m`
ANOMESANTERIOR=`date -d "-1 month" +%Y%m`

## incrementando arquivos de cada dado em separado

## reversao
QUERY1=`echo "USE ptwiki_p; select count(*) FROM ( select r.*, EXTRACT(MONTH FROM CAST(r.rev_timestamp AS DATETIME)) AS MES, EXTRACT(YEAR FROM CAST(r.rev_timestamp AS DATETIME)) AS ANO FROM revision r INNER JOIN revision rp ON  r.rev_parent_id = rp.rev_id  INNER JOIN revision rpp ON rp.rev_parent_id = rpp.rev_id WHERE ((r.rev_timestamp > "$ANOMESANTERIOR"01000000 and r.rev_timestamp < "$ANOMESATUAL"01000000) ) and r.rev_sha1  = rpp.rev_sha1) a GROUP BY MES, ANO;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes_temp
sed "/Reversões/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes_temp

## redirecionamento
QUERY1=`echo "USE ptwiki_p; select count(*) from page, revision where page_id = rev_page and page_is_redirect = 1 and page_namespace in (0,102) and rev_parent_id = 0 and rev_timestamp < "$ANOMESATUAL"01000000;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos_temp
sed "/Redirecionamentos/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos_temp

## wikipedistas
QUERY1=`echo "USE ptwiki_p; select count(*) from (select rev_user, count(*) as edits from page, revision where page_id = rev_page and page_namespace in (0,102) and rev_timestamp < "$ANOMESATUAL"01000000 and rev_user <> 0 and  rev_user NOT IN (SELECT ug_user FROM user_groups WHERE ug_group = 'bot') group by rev_user) a where edits > 9;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas_temp
sed "/Wikipedistas/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas_temp

## NovosWikipedistas

VALORATUAL=`head -2 /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas |tail -1`
VALORANTERIOR=`head -3 /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas |tail -1`
RESULTADO=`echo $(( $VALORATUAL - $VALORANTERIOR ))`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas_temp
sed "/NovosWikipedistas/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas_temp

## artigos
QUERY1=`echo "USE ptwiki_p;  select count(*) from (select distinct page_id from page, revision, pagelinks where page_id = pl_from and page_id = rev_page and page_namespace in (0,102) and rev_parent_id = 0 and page_is_redirect = 0 and rev_timestamp < "$ANOMESATUAL"01000000 ) a;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos_temp
sed "/Artigos/{p;s/.*/$RESULTADO/;}" artigos_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos_temp

## artigospordia
echo $(date --date "`date +%m/01/%Y` yesterday" +%d) > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/dias
DIAS=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/dias`
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/dias
VALORATUAL=`head -2 /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos |tail -1`
VALORANTERIOR=`head -3 /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos |tail -1`
RESULTADO=`echo $(( $VALORATUAL / $DIAS - $VALORANTERIOR / $DIAS ))`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia_temp
sed "/ArtigosPorDia/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia_temp

## edicoes mes (inclui bots)
QUERY1=`echo "USE ptwiki_p; select count(*) from revision, page where rev_page = page_id and page_namespace in (0,102) and rev_timestamp > "$ANOMESANTERIOR"01000000 and rev_timestamp < "$ANOMESATUAL"01000000;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoesmes /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoesmes_temp
sed "/EdiçõesMês/{p;s/.*/$RESULTADO/;}" edicoesmes_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoesmes
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoesmes_temp

## edicoes humanos (sem bots)
QUERY1=`echo "USE ptwiki_p; select COUNT(*) from (select rev_id, EXTRACT(MONTH FROM CAST(rev_timestamp AS DATETIME)) AS MES, EXTRACT(YEAR FROM CAST(rev_timestamp AS DATETIME)) AS ANO from revision, page where rev_page = page_id and page_namespace in (0,102) and rev_timestamp > "$ANOMESANTERIOR"01000000 and rev_timestamp < "$ANOMESATUAL"01000000 and  rev_user not in (SELECT ug_user FROM user_groups WHERE ug_group = 'bot') ) a group by MES, ANO order by ANO DESC, MES DESC;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos_temp
sed "/EdiçõesHumanos/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos_temp

## media edicoes (media de revisoes por artigo)
ARTIGOS=`head -2 /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos |tail -1`
QUERY1=`echo "USE ptwiki_p; select count(*) from revision inner join page on rev_page = page_id where page_namespace in (0,102) and rev_timestamp < "$ANOMESATUAL"01000000;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
REVISOES=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
RESULTADO=$(echo |awk '{ print '''$REVISOES'''/'''$ARTIGOS'''}')


mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes_temp
sed "/MediaEdições/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes_temp

## ativos

QUERY1=`echo "USE ptwiki_p; select count(*) from ( select rev_user, count(*) as edicoes from revision inner join page on rev_page = page_id where page_namespace in (0,102) and rev_user not in (select ug_user from user_groups where ug_group = 'bot') and (rev_timestamp > "$ANOMESANTERIOR"01000000 and rev_timestamp < "$ANOMESATUAL"01000000) group by rev_user) a where edicoes > 4;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos_temp
sed "/Ativos/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos_temp

## muito ativos

QUERY1=`echo "USE ptwiki_p; select count(*) from ( select rev_user, count(*) as edicoes from revision inner join page on rev_page = page_id where page_namespace in (0,102) and rev_user not in (select ug_user from user_groups where ug_group = 'bot') and (rev_timestamp > "$ANOMESANTERIOR"01000000 and rev_timestamp < "$ANOMESATUAL"01000000) group by rev_user) a where edicoes > 99;"`
mysql --defaults-file=~/replica.my.cnf -h ptwiki.labsdb -e "$QUERY1" |sed 1d > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery
RESULTADO=`cat /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery`
mv /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos_temp
sed "/MuitoAtivos/{p;s/.*/$RESULTADO/;}" /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos_temp > /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos_temp

# fim atualizacao de dados
rm /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/resultadoquery # apagando arquivo usado temporariamente

# gerando novo arquivo central com dados e fazendo backup do antigo
mv /data/project/ptwikis/ptwikis/static/timeline/data/linha_data.tsv /data/project/ptwikis/ptwikis/static/timeline/data/linha_data.tsv.bkp
paste /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/months /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/wikipedistas /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/novoswikipedistas /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/ativos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/muitoativos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/artigospordia /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/mediaedicoes /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoesmes /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/edicoeshumanos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/redirecionamentos /data/project/ptwikis/ptwikis/static/timeline/data/rawdata/reversoes > /data/project/ptwikis/ptwikis/static/timeline/data/linha_data.tsv


