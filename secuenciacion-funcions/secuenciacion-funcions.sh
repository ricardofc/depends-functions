#!/bin/bash
# Author: Ricardo Feijoo Costa <ricardofc.sistemas@gmail.com>

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>

# DATA: 2013-06-07 19:18:31.000000000 +0200

# reports/  Cartafol onde se gardan os informes

#FUNCIÓNS
axuda() {
clear
echo
echo -ne '\e[01;33m'
echo '#######################################################'
echo -ne '\e[01;33m'
echo Execución errónea. Exemplo execución:
echo -ne '\e[00m'
echo -ne '\e[01;77m'
echo bash $0 script.sh
echo -ne '\e[01;33m'
echo '#######################################################'
echo -e '\e[00m'
echo
}

limpeza_temporal() {
if [ -d reports ]; then
  rm -f reports/debug/* > /dev/null 2>&1
  rm -f reports/depends/* > /dev/null 2>&1
  rm -f reports/diagrams/* > /dev/null 2>&1
  rm -f reports/dots/* > /dev/null 2>&1
  rm -f reports/error/* > /dev/null 2>&1
  rm -f reports/functions/* > /dev/null 2>&1
  rm -f reports/main/* > /dev/null 2>&1
  rm -f reports/out-functions/* > /dev/null 2>&1
  rm -f reports/tmp/* > /dev/null 2>&1
fi
}


##Debuxar dependencias funcións
procura_dependencias() {
for i in $NLINHAANDFEXIST
do
  NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
  FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
  for j in ${FEXISTS}
  do
    FUNCIONSDENTRO=$(cat reports/tmp/funcions_${FEXIST}.tmp | sed '1d' | awk '{print $2}' | grep ^$j | grep -v '()' | tr -d ' ')
    if ! [ -z "$FUNCIONSDENTRO" ]; then
      NUMCONCURRECENCIASMESMAFUNCION=$(cat reports/tmp/funcions_${FEXIST}.tmp | awk '{print $2}' | grep ^$j | grep -v '()' | tr -d ' ' | wc -l)
      for k in $FUNCIONSDENTRO
      do
        NLINHAFUNCIONSDENTRO=$(cat reports/tmp/funcions_${FEXIST}.tmp | awk -v myvar="$k" '$2==myvar { print }' | awk '{print $1}')
        #Entón xa podemos debuxar a primeira dependencia:
      done
      for l in $NLINHAFUNCIONSDENTRO
      do
        DEPENDENCIA=$(echo $NLINHAFEXIST ${FEXIST} '-->' $l $k | grep -v '>$')
        echo $DEPENDENCIA | sed '/^$/d' >> reports/tmp/dependencia-1-nivel_${FEXIST}.tmp
        echo $DEPENDENCIA | sed '/^$/d' >> reports/tmp/dependencia-1-nivel.tmp
      done
    fi
    if [ -f reports/tmp/dependencia-1-nivel_${FEXIST}.tmp ]; then
      cat reports/tmp/dependencia-1-nivel_$FEXIST.tmp | sort -n | uniq > reports/tmp/dependencia-un-nivel_$FEXIST.tmp
    fi
  done
done
if [ -f reports/tmp/dependencia-1-nivel.tmp ]; then
  cat reports/tmp/dependencia-1-nivel.tmp | sort -n | uniq | awk '{ if ( $2 == $5 ) print}'> reports/tmp/dependencia-un-nivel-recursivo.tmp
  cat reports/tmp/dependencia-1-nivel.tmp | sort -n | uniq | awk '{ if ( $2 != $5 ) print}'> reports/tmp/dependencia-un-nivel-nonrecursivo.tmp
  cat reports/tmp/dependencia-1-nivel.tmp | sort -n | uniq > reports/tmp/dependencia-un-nivel.tmp
else
  echo -ne '\e[01;33m'
  echo 'Non existen dependencias entre funcions.'
  echo -e  "As funcións que existen son:"
  for i in $NLINHAANDFEXIST
  do
    NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
    FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
    echo -ne "  $NLINHAFEXIST $FEXIST\n"
  done
  echo -ne '\e[00m'
  exit
fi
}

depuracion() {
#Funcións que non se executan
for i in $NLINHAANDFEXIST
do
  NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
  FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
  grep -o $FEXIST reports/tmp/dependencias-funcions.tmp > /dev/null
  if [ $? -ne 0 ]; then
    grep -o $FEXIST reports/tmp/chamada-funcions.tmp > /dev/null
    if [ $? -ne 0 ]; then
      echo "$NLINHAFEXIST $FEXIST" >> reports/tmp/depuracion.tmp
    fi
  fi
done
}


repetir_simplificar() {
    while read line
    do
      while read lina
      do
        PRIMER=$(echo $lina | awk -F'->' '{print $1}')
        if [ "$M" -eq 1 ];then
          grep "$lina" reports/tmp/diagrama-dependencias-funcions.dot > reports/tmp/diagrama-dependencias-funcions-concurrencia.dot
        else
          grep "$lina" reports/tmp/diagrama-dependencias-funcions-simplificada2.dot > /dev/null
          if [ $? -eq 0 ]; then
            grep "$lina" reports/tmp/diagrama-dependencias-funcions-simplificada2.dot > reports/tmp/diagrama-dependencias-funcions-concurrencia.dot
          else
            grep "$lina" reports/tmp/diagrama-dependencias-funcions.dot > reports/tmp/diagrama-dependencias-funcions-concurrencia.dot
          fi
          grep -v "$lina" reports/tmp/diagrama-dependencias-funcions-simplificada2.dot > reports/tmp/diagrama-dependencias-funcions-simplificada2a.dot
          cp -p reports/tmp/diagrama-dependencias-funcions-simplificada2a.dot reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
        fi
        awk -F"$lina" '{print $1}' reports/tmp/diagrama-dependencias-funcions-concurrencia.dot | sed -e '/^$/d' -e "s/$/$PRIMER/g" -e 's/ *$//g' | uniq > reports/tmp/temporalvarawk.tmp
        if [ -f reports/tmp/diagrama-dependencias-funcions-simplificada2.dot ]; then
          while read lina2
          do
            grep "$lina2$" reports/tmp/diagrama-dependencias-funcions-simplificada2.dot > reports/tmp/temporal.tmp
            if [ $? -ne 0 ]; then
              echo "$lina2" >> reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
            fi
          done <reports/tmp/temporalvarawk.tmp
        else
          cat reports/tmp/temporalvarawk.tmp >> reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
      fi
          grep '\[' reports/tmp/diagrama-dependencias-funcions-concurrencia.dot > /dev/null
          if [ $? -ne 0 ];then
            awk -F"$lina" '{print $2}' reports/tmp/diagrama-dependencias-funcions-concurrencia.dot | sed -e '/^$/d' -e "s/^/$lina/g" -e 's/ *$//g' | uniq >> reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
          else
            awk -F"$lina" '{print $2}' reports/tmp/diagrama-dependencias-funcions-concurrencia.dot | sed -e '/^$/d' -e "s/^/$lina/g" | awk -F[ '{$NF="";print}' | sed 's/ *$//g' | uniq >> reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
          fi
      done <$line
      M=$(($M+1))
    done <reports/tmp/simplificar2.tmp
}


diagrama() {
#Pendente: Outras distros distintas a Debian
dpkg -l | grep -i graphviz > /dev/null
if [ $? -eq 0 ]; then
  count=1
  while read ler
  do
    FLOW=$(echo $ler | awk '{print $3"-"$NF}')
    echo "digraph diagrama_${count} {" > reports/tmp/diagrama-dependencias-funcions_${count}_${FLOW}.dot
    echo 'graph [bgcolor="#f2f0fd",label=<<TABLE BORDER="0" HREF="http://eporquenon.abraix.com"><TR><TD><IMG SRC="'"$LOGOABRAIX"'"/></TD></TR></TABLE>>,URL="http://eporquenon.abraix.com"]' >> reports/tmp/diagrama-dependencias-funcions_${count}_${FLOW}.dot
    echo $ler | sed -e "s/@//g"  -e 's/ --> /" -> "/g' -e "s/^ /\"/g" -e 's/$/" [label=" '$count'"]/g' >> reports/tmp/diagrama-dependencias-funcions_${count}_${FLOW}.dot
    echo '}' >> reports/tmp/diagrama-dependencias-funcions_${count}_${FLOW}.dot
    echo $ler | sed -e "s/@//g"  -e 's/ --> /" -> "/g' -e "s/^ /\"/g" -e 's/$/" [label=" '$count'"]/g'>> reports/tmp/diagrama-dependencias-funcions.dot
    count=$((${count}+1))
  done <reports/tmp/dependencias-funcions.tmp
  if [ -f reports/tmp/nodes_only.tmp ]; then
    cat reports/tmp/nodes_only.tmp >> reports/tmp/diagrama-dependencias-funcions.dot
  fi
  cat reports/tmp/diagrama-dependencias-funcions.dot | grep '[[:digit:]]' | sort -n | uniq > reports/tmp/diagrama-dependencias-funcions-full.dot
  echo 'digraph diagrama {' > reports/tmp/diagrama-dependencias-funcions.dot
  echo 'graph [bgcolor="#f2f0fd",label=<<TABLE BORDER="0" HREF="http://eporquenon.abraix.com"><TR><TD><IMG SRC="'"$LOGOABRAIX"'"/></TD></TR></TABLE>>,URL="http://eporquenon.abraix.com"]' >> reports/tmp/diagrama-dependencias-funcions.dot
  cat reports/tmp/diagrama-dependencias-funcions-full.dot >> reports/tmp/diagrama-dependencias-funcions.dot
  echo '}' >> reports/tmp/diagrama-dependencias-funcions.dot
  for i in $(seq 1 $((${count}-1)))
  do
    NAMEFICH=$(ls reports/tmp/diagrama-dependencias-funcions_${i}_*.dot | awk -F. '{print $1}')
##    dot ${NAMEFICH}.dot -Tpng -o ${NAMEFICH}.png
    dot ${NAMEFICH}.dot -Tsvg -o ${NAMEFICH}.svg
  done
##  dot reports/tmp/diagrama-dependencias-funcions.dot -Tpng -o reports/tmp/diagrama-global.png
  dot reports/tmp/diagrama-dependencias-funcions.dot -Tsvg -o reports/tmp/diagrama-global.svg

# Realidade diagrama-global
  ls reports/tmp/dependencia-un-nivel_*.tmp > reports/tmp/une_dependencias.tmp
  if [ -f reports/tmp/depuracion.tmp ]; then
    while read line
    do
    CAMPO2=$(echo $line | awk '{print $NF}')
    grep -v "$CAMPO2" reports/tmp/une_dependencias.tmp > reports/tmp/une_dependencias2.tmp
    cp -p reports/tmp/une_dependencias2.tmp reports/tmp/une_dependencias.tmp > /dev/null
    done <reports/tmp/depuracion.tmp
  fi
  while read line
  do
  NUMLINHAS=$(cat $line | wc -l)
  if [ "$NUMLINHAS" -gt 1 ];then
    echo $line >> reports/tmp/simplificar.tmp
  fi
  done <reports/tmp/une_dependencias.tmp

  if [ -f reports/tmp/simplificar.tmp ]; then
    while read line
    do
      NAMEFUNCION=$(echo $line | awk -F'reports/tmp/dependencia-un-nivel_' '{print $NF}' | awk -F'.tmp' '{print $1}')
      while read intline
      do
        NUMCAMPOS=$(echo $intline | awk '{print NF}')
        for i in $(seq 1 $NUMCAMPOS)
        do
          VAR=$(echo $intline | awk -v myvar="$i" "{print $"myvar"}" | sed -e 's/"//g')
            if [ "$VAR" = "$NAMEFUNCION" ]; then
              echo $NAMEFUNCION $i >> reports/tmp/verver.tmp
            fi
        done
      done <reports/tmp/diagrama-dependencias-funcions.dot
      grep $NAMEFUNCION reports/tmp/verver.tmp | sort -n | uniq | head -1 >> reports/tmp/ver.tmp
    done <reports/tmp/simplificar.tmp
    sort -n -k2 -o reports/tmp/ver.tmp reports/tmp/ver.tmp
    while read line
    do
      echo $line | awk '{print $1}' | sed -e 's|^|reports/tmp/dependencia-un-nivel_|g' -e 's|$|.tmp|g' >> reports/tmp/simplificar3.tmp
    done < reports/tmp/ver.tmp
    while read line
    do
      while read lina
      do
        echo $lina | sed -e 's/ --> /" -> "/g' -e "s/^ /\"/g" -e "s/^/\"/g" -e "s/$/\"/g" >> ${line}_simplificar2.tmp
      done <$line
      echo ${line}_simplificar2.tmp >> reports/tmp/simplificar2.tmp
    done <reports/tmp/simplificar3.tmp

    M=1
    repetir_simplificar

    if [ -f reports/tmp/nodes_only.tmp ]; then
      VARSORTRAIZ=$(cat reports/tmp/dependencias-funcions.tmp | grep '@' | awk '{print $2}' | sort | uniq)
      VARSORTNODESOLNLY=$(cat reports/tmp/nodes_only.tmp | awk '{print $1}' | sed 's/"//g')
      P=1
      for i in $VARSORTNODESOLNLY
      do
        if [ $i -lt $VARSORTRAIZ ]; then
          grep $i reports/tmp/nodes_only.tmp >> reports/tmp/diagrama-dependencias-funcions-simplificada3.dot
        else
          if [ $P -eq 1 ]; then
            cat reports/tmp/diagrama-dependencias-funcions-simplificada2.dot >> reports/tmp/diagrama-dependencias-funcions-simplificada3.dot
            grep $i reports/tmp/nodes_only.tmp >> reports/tmp/diagrama-dependencias-funcions-simplificada3.dot
            P=$(($P+1))
          else
            grep $i reports/tmp/nodes_only.tmp >> reports/tmp/diagrama-dependencias-funcions-simplificada3.dot
          fi
        fi
      done

    cp -p reports/tmp/diagrama-dependencias-funcions-simplificada3.dot reports/tmp/diagrama-dependencias-funcions-simplificada2.dot
    fi
    echo 'digraph diagram {' > reports/tmp/diagrama-dependencias-funcions-simplificada.dot
    echo 'graph [bgcolor="#f2f0fd",label=<<TABLE BORDER="0" HREF="http://eporquenon.abraix.com"><TR><TD><IMG SRC="'"$LOGOABRAIX"'"/></TD></TR></TABLE>>,URL="http://eporquenon.abraix.com"]' >> reports/tmp/diagrama-dependencias-funcions-simplificada.dot
    cat reports/tmp/diagrama-dependencias-funcions-simplificada2.dot >> reports/tmp/diagrama-dependencias-funcions-simplificada.dot
    echo '}' >> reports/tmp/diagrama-dependencias-funcions-simplificada.dot
##    dot reports/tmp/diagrama-dependencias-funcions-simplificada.dot -Tpng -o reports/tmp/diagrama-global-simplificado.png
    dot reports/tmp/diagrama-dependencias-funcions-simplificada.dot -Tsvg -o reports/tmp/diagrama-global-simplificado.svg
    mv reports/tmp/diagrama-global-simplificado.svg reports/diagrams/diagrama-global-simplificado.svg
##    firefox reports/diagrams/diagrama-global-simplificado.svg
  else
    mv reports/tmp/diagrama-global.svg reports/diagrams/diagrama-global.svg
##    firefox reports/diagrams/diagrama-global.svg
  fi

else
  echo -ne '\e[01;77m'
  echo -e "Para poder amosar a/s dependencia/s nunha imaxe instala o paquete graphviz, por exemplo: \n apt-get -y install graphviz"
  echo -ne '\e[00m'
fi
}

procura_inicio_fin_raiz() {
for i in $NLINHAANDFEXIST
do
  NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
  FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
  cat reports/tmp/dependencias-funcions2.tmp | awk -v myvar="$FEXIST" -v myvar2="$NLINHAFEXIST" '{ if ( $NF == myvar) print $0,"-->",myvar2, $NF}' >> reports/tmp/dependencias-funcions3.tmp
done
while read line
do
  CAMPO1=$(echo $line | awk '{print $1}')
  CAMPO2=$(echo $line | awk '{print $2}')
  cat reports/tmp/dependencias-funcions3.tmp | awk -v myvar1="$CAMPO1" -v myvar2="$CAMPO2" '{ if ( $3 == myvar2) print "@@",myvar1,myvar2,"-->",$0}' | sed "s|--> @@|-->|g" >> reports/tmp/dependencias-funcions.tmp
done <reports/tmp/chamada-funcions.tmp
sort -o reports/tmp/dependencias-funcions.tmp reports/tmp/dependencias-funcions.tmp
depuracion
diagrama
}

apuntalar_raiz() {
for i in $NLINHAANDFEXIST
do
  NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
  FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
  for j in $(cat reports/tmp/g.tmp)
  do
    if [ "$FEXIST" = "$j" ]; then
      if  [ -z "$n" ]; then
        sed -i "s/$NLINHAFEXIST $FEXIST/@@ $NLINHAFEXIST $FEXIST/g" reports/tmp/dependencia-un-nivel.tmp
        cat reports/tmp/dependencia-un-nivel.tmp | sort -n | uniq > reports/tmp/dependencias-funcions2.tmp
      else
        sed -i "s/$NLINHAFEXIST $FEXIST/@@ $NLINHAFEXIST $FEXIST/g" reports/tmp/final2.tmp
        cat reports/tmp/final2.tmp | sort -n | uniq > reports/tmp/dependencias-funcions2.tmp
      fi
    fi
  done
done
procura_inicio_fin_raiz
}

repetir2() {
z=0
#Ven dada na primeira chamada a repetir2 a variable n=1
while read line1
do
  if [ "$n" -eq 1 ]; then
    VARN=$(echo "$line1")
  else
    for i in $(seq 2 $n)
    do
    VARN="${VARNM} --> $line1"
#   VARN=$(echo "$line1")
#   VARN=$(echo "$line1 --> $line2")
#   VARN=$(echo "$line1 --> $line2 --> $line3")
#   Agora non se cambia read line1, co cal,  cada vez que se cambia o ficheiro co parámetro ULTIMO cambia line1
#   VARN=$(echo "$line1")
#   VARN=$(echo "$line1 --> $line1")
#   VARN=$(echo "$line1 --> $line1 --> $line1")
    done
  fi

  VARNM=$(echo ${VARN})

  NUMULTIMO=$(echo ${VARNM} | awk '{print NF}')
  NUMANTERIOR=$((${NUMULTIMO}-3))
  ANTERIOR=$(echo ${VARNM} | cut -d ' ' -f$NUMANTERIOR)
  ULTIMO=$(echo ${VARNM} | awk '{print $NF}')

    if [ "$z" -eq 1 ]; then
      COMPARAR=$(echo ${VARNM} | awk '{print $1,$2}')
      grep  "$COMPARAR" reports/tmp/final.tmp | tail -1 > /dev/null
      if [ $? -eq 0 ]; then
        VARCOMPARAR=$(grep  "$COMPARAR" reports/tmp/final.tmp | tail -1 | awk -F"$COMPARAR" '{print $1}')
        echo ${VARCOMPARAR} ${VARNM} >> reports/tmp/final.tmp
        z=$(($z+1))
      fi
    else
        if [ "$n" -ge 2 ] && [ "$z" -ge 0 ]; then
          COMPARAR=$(echo ${VARNM} | awk '{print $1,$2}')
          grep  "$COMPARAR" reports/tmp/final.tmp | tail -1 > /dev/null
          if [ $? -eq 0 ]; then
            VARCOMPARAR=$(grep  "$COMPARAR" reports/tmp/final.tmp | tail -1 | awk -F"$COMPARAR" '{print $1}')
            echo ${VARCOMPARAR} ${VARNM} >> reports/tmp/final.tmp
            z=$(($z+1))
          fi
        else
          echo ${VARNM} >> reports/tmp/final.tmp
        fi
    fi


  if [ "$ANTERIOR" != "$ULTIMO" ] && [ -f "reports/tmp/dependencia-un-nivel_$ULTIMO.tmp" ]; then
    n=$(($n+1))
    repetir2
  fi
echo ${VARCOMPARAR} ${VARNM} >> reports/tmp/final2.tmp
n=1
z=1
done <reports/tmp/dependencia-un-nivel_$ULTIMO.tmp
}

procura_funcions_raiz() {
for i in $FEXISTS
do
  NUMFRAIZ=$(cat reports/tmp/e2.tmp | grep $i | awk '{print $1}')
  FRAIZ=$(cat reports/tmp/e.tmp | grep -o $i)
  echo $FRAIZ >> reports/tmp/f.tmp
  echo $NUMFRAIZ $FRAIZ  >> reports/tmp/f2.tmp
done
cat reports/tmp/f2.tmp | sort -n | uniq | sed '/^$/d' > reports/tmp/chamada-funcions.tmp
cat reports/tmp/f.tmp | sort | uniq | sed '/^$/d' | awk '{print $1}' >> reports/tmp/g.tmp
if ! [ -s reports/tmp/g.tmp ]; then
  echo -ne '\e[01;33m'
  echo O script non posúe chamadas a funcións.
  echo -ne '\e[00m'
  exit
fi

while read line
do
  ULTIMO=$(echo $line | awk '{print $NF}')
  echo $ULTIMO
  if [ "$line" != "$ULIIMO" ] && [ -f "reports/tmp/dependencia-un-nivel_$ULTIMO.tmp" ]; then
    n=1
    repetir2
  fi
  NUMFEXIST=$(echo $line | awk '{print $1}')
  grep -o $ULTIMO reports/tmp/dependencia-un-nivel.tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo \""$NUMFEXIST $ULTIMO"\" >> reports/tmp/nodes_only.tmp
  fi
done <reports/tmp/chamada-funcions.tmp

apuntalar_raiz
}

estudo_execucion() {
  if [ -f reports/tmp/erros.tmp ];then
    mv reports/tmp/erros.tmp reports/error
  fi
  mv reports/tmp/chamada-funcions.tmp reports/main
  mv reports/tmp/dependencia-un-nivel*recursivo.tmp reports/depends
  mv reports/tmp/dependencia-un-nivel.tmp reports/depends
  mv reports/tmp/dependencias-funcions.tmp reports/depends
  if [ -f reports/tmp/depuracion.tmp ];then
    mv reports/tmp/depuracion.tmp reports/debug
  fi
  mv reports/tmp/diagrama*.svg reports/diagrams
  mv reports/tmp/diagrama-dependencias-funcions_*_*.dot reports/dots
  mv reports/tmp/diagrama-dependencias-funcions.dot reports/dots
  mv reports/tmp/diagrama-dependencias-funcions-simplificada.dot reports/dots
  mv reports/tmp/funcions*.tmp reports/functions
  mv reports/tmp/e.tmp reports/out-functions/without-number.tmp
  mv reports/tmp/e2.tmp reports/out-functions/with-number.tmp
  if [ -f reports/tmp/nodes_only.tmp ];then
    mv reports/tmp/nodes_only.tmp reports/depends
  fi
  rm -f reports/tmp/*
  clear
  echo -ne '\e[01;77m'
  echo
  echo "Ler README.html ou README.txt"
  ## cat README.txt
  firefox README.html
  echo -ne '\e[00m'
}

##main()
if [ "$#" -eq 1 ] && [ -f "$1" ]; then
bash -n $1 2>reports/tmp/erros.tmp
if [ $? -eq 0 ]; then
  limpeza_temporal

  #VARIABLES
  LOGOABRAIX="$PWD/logo-abraix.jpg"
  NLINHAS=$(cat $1 | wc -l)
  NLINHAANDFEXIST=$(nl -ba -s@ $1 | grep '()' | grep -vE '#|=|"' | sed -e 's/[ \t]*//g' -e 's/\s*//g' | awk -F\( '{print $1}')
  FEXISTS=$(nl -ba -s@ $1 | grep '()' | grep -vE '#|=|"' | sed -e 's/[ \t]*//g' -e 's/\s*//g' | awk -F\( '{print $1}' | awk -F@ '{print $2}' | sed 's/^function//g')
  if ! [ -z "$FEXISTS" ];then
    ##echo --------------------------------------------
    for i in $NLINHAANDFEXIST
    do
      NLINHAFEXIST=$(echo $i | awk -F@ '{print $1}')
      FEXIST=$(echo $i | awk -F@ '{print $2}' | sed 's/^function//g')
      LISTARINICIO=$((${NLINHAS}-${NLINHAFEXIST}+1))
      NFINFEXIST=$(nl -ba $1 | tail -$LISTARINICIO | grep -E '}$|} #' | grep -v '\$' | head -1 | awk '{print $1}')
      LISTAR=$((${NFINFEXIST}-${NLINHAFEXIST}+1))
      #GARDAR CADA FUNCIÓN NUN FICHEIRO
      nl -ba $1 | tail -$LISTARINICIO | head -$LISTAR  > reports/tmp/funcions_$FEXIST.tmp
      #GARDAR TÓDALAS FUNCIÓNS NUN FICHEIRO
      nl -ba $1 | tail -$LISTARINICIO | head -$LISTAR  >> reports/tmp/funcions.tmp
    ##  echo --------------------------------------------
    ##  sleep 1
      SABERNUMLINHASFUNCIONS=$(echo $SABERNUMLINHASFUNCIONS;nl -ba $1 | tail -$LISTARINICIO | head -$LISTAR | awk '{print $1}')
    done

    procura_dependencias

    #Ver execucion de funcións fora das funcións listadas --> debuxar dependencias
    for i in $SABERNUMLINHASFUNCIONS
    do
      FILTRO="$FILTRO"' | awk "{ if ( $1 != '"$i"' ) { print } }"'
    done

    echo -ne '\e[01;77m'
    echo ----------------------------- FUNCIÓNS RAIZ ------------------------------------
    echo -ne '\e[01;36m'
    FILTER=$(echo nl -ba $1 $FILTRO | sed -e "s/\"{/'{/g" -e "s/}\"/}'/g")
    FILTRADO=$(echo $FILTER "| grep -v '#' | sed '/^$/d'")
    echo $FILTRADO > reports/tmp/b2.tmp
    bash reports/tmp/b2.tmp > reports/tmp/e2.tmp

    NLINHADEFFUNCION=$(cat reports/tmp/e2.tmp | grep '()' | grep '{' | grep -vE '#|=' | awk '{print $1}')
    if ! [ -z "$NLINHADEFFUNCION" ];then
      NLINHAFINDEFFUNCION=$(cat reports/tmp/e2.tmp | grep '}"$' | grep -v '\$' | head -1 | awk '{print $1}')
      for i in $(seq "${NLINHADEFFUNCION}" "${NLINHAFINDEFFUNCION}")
      do
        cat reports/tmp/e2.tmp | awk '{ if ( $1 != '"$i"' ) print }' > reports/tmp/e3.tmp
        cp -p reports/tmp/e3.tmp reports/tmp/e2.tmp
      done
    fi

    cat reports/tmp/e2.tmp | awk '{ $1 =""; print }' | grep -v '#' | sed '/^$/d' > reports/tmp/e.tmp

    procura_funcions_raiz
    echo -ne '\e[00m'
    echo -ne '\e[01;77m'
    echo ----------------------------------- FIN ----------------------------------------
    echo -ne '\e[00m'
    estudo_execucion
  else
  echo -ne '\e[01;77m'
  echo "O script non posúe funcións."
  echo -ne '\e[00m'
  fi
else
  echo -ne '\e[01;77m'
  echo "Erro de sintaxe no script. Revise a sintaxe do mesmo."
  echo -ne '\e[00m'
  echo -ne '\e[01;33m'
  cat reports/tmp/erros.tmp
  echo -ne '\e[00m'
fi
else
  axuda
  if ! [ -f "$1" ];then
    echo -ne '\e[01;77m'
    echo "O script a estudar non existe. Revise a ruta do script."
    echo -ne '\e[00m'
  fi
fi
