# EQL EBNF [^1-app-chap:EQL-EBNF] {#app-chap:EQL-EBNF}

[^1-app-chap:EQL-EBNF]: The EBNF presented here is an updated version of the EBNF of the `EQL` vignette.

This chapter presents the EBNF [@garshol:2003a] that describes version 2 of the EQL. As the original EBNF adapted from @john:2012a was written in German, some of the abbreviation terms were translated into English abbreviations (e.g., DOMA is the abbreviation for the German term **Dom**inanz**a**bfrage and the newly translated DOMQ is the abbreviation for the English term **dom**ination **q**uery).

## Terminal symbols of EQL2 (operators) and their meaning

The terminal symbols described below are listed in descending order by their binding priority.

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Symbol </th>
   <th style="text-align:left;"> Meaning </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> # </td>
   <td style="text-align:left;"> Result modifier (projection) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> , </td>
   <td style="text-align:left;"> Parameter list separator </td>
  </tr>
  <tr>
   <td style="text-align:left;"> == </td>
   <td style="text-align:left;"> Equality (new in version 2 of the EQL; added for cleaner syntax) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> = </td>
   <td style="text-align:left;"> Equality (optional; for backwards compatibility) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> != </td>
   <td style="text-align:left;"> Inequality </td>
  </tr>
  <tr>
   <td style="text-align:left;"> =~ </td>
   <td style="text-align:left;"> Regular expression matching </td>
  </tr>
  <tr>
   <td style="text-align:left;"> !~ </td>
   <td style="text-align:left;"> Regular expression non-matching </td>
  </tr>
  <tr>
   <td style="text-align:left;"> &gt; </td>
   <td style="text-align:left;"> Greater than </td>
  </tr>
  <tr>
   <td style="text-align:left;"> &gt;= </td>
   <td style="text-align:left;"> Equal to or greater than </td>
  </tr>
  <tr>
   <td style="text-align:left;"> &lt; </td>
   <td style="text-align:left;"> Less than </td>
  </tr>
  <tr>
   <td style="text-align:left;"> &gt;= </td>
   <td style="text-align:left;"> Equal to or less than </td>
  </tr>
  <tr>
   <td style="text-align:left;"> | </td>
   <td style="text-align:left;"> Alternatives separator </td>
  </tr>
  <tr>
   <td style="text-align:left;"> &amp; </td>
   <td style="text-align:left;"> Conjunction of equal rank </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ^ </td>
   <td style="text-align:left;"> Dominance conjunction </td>
  </tr>
  <tr>
   <td style="text-align:left;"> -&gt; </td>
   <td style="text-align:left;"> Sequence operator </td>
  </tr>
</tbody>
</table>

## Terminal symbols of EQL2 (brackets) and their meanings.

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Symbol </th>
   <th style="text-align:left;"> Meaning </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ' </td>
   <td style="text-align:left;"> Quotes literal string </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ( </td>
   <td style="text-align:left;"> Function parameter list opening bracket </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ) </td>
   <td style="text-align:left;"> Function parameter list closing bracket </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [ </td>
   <td style="text-align:left;"> Sequence or dominance-enclosing opening bracket </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ] </td>
   <td style="text-align:left;"> Sequence or dominance-enclosing closing bracket </td>
  </tr>
</tbody>
</table>

## Terminal symbols of EQL2 (functions) and their meanings.


<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Symbol </th>
   <th style="text-align:left;"> Meaning </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Start </td>
   <td style="text-align:left;"> Start </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Medial </td>
   <td style="text-align:left;"> Medial </td>
  </tr>
  <tr>
   <td style="text-align:left;"> End </td>
   <td style="text-align:left;"> Final </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Num </td>
   <td style="text-align:left;"> Count </td>
  </tr>
</tbody>
</table>


## Formal description of EMU Query Language Version 2

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> EBNF_term </th>
   <th style="text-align:left;"> Abbreviation </th>
   <th style="text-align:left;"> Conditions </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> EQL = CONJQ | SEQQ | DOMQ; </td>
   <td style="text-align:left;"> **E**MU **Q**uery **L**anguage </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DOMQ = &quot;[&quot;, ( CONJQ | DOMQ | SEQQ ), &quot;^&quot;, ( CONJQ | DOMQ | SEQQ ), &quot;]&quot;; </td>
   <td style="text-align:left;"> **dom**inance **q**uery </td>
   <td style="text-align:left;"> levels must be hierarchically associated </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SEQQ = &quot;[&quot;, ( CONJQ | SEQQ | DOMQ ), &quot;-&gt;&quot;, ( CONJQ | SEQQ | DOMQ ), &quot;]&quot;; </td>
   <td style="text-align:left;"> **seq**uential **q**uery </td>
   <td style="text-align:left;"> levels must be linearly associated </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CONJQ = { &quot;[&quot; }, SQ, { &quot;&amp;&quot;, SQ }, { &quot;]&quot; }; </td>
   <td style="text-align:left;"> **conj**unction **q**uery </td>
   <td style="text-align:left;"> levels must be linearly associated </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SQ = LABELQ | FUNCQ; </td>
   <td style="text-align:left;"> **s**imple **q**uery </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LABELQ = [ &quot;#&quot; ], LEVEL, ( &quot;=&quot; | &quot;==&quot; | &quot;!=&quot; | &quot;=~&quot; | &quot;!~&quot; ), LABELALTERNATIVES; </td>
   <td style="text-align:left;"> **label** **q**uery </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FUNCQ = POSQ | NUMQ; </td>
   <td style="text-align:left;"> **fun**ction **q**uery </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> POSQ = POSFCT, &quot;(&quot;, LEVEL, &quot;,&quot;, LEVEL, &quot;)&quot;, &quot;=&quot;, &quot;0&quot; | &quot;1&quot;; </td>
   <td style="text-align:left;"> **position** **q**uery </td>
   <td style="text-align:left;"> levels must be hierarchically associated; second level determines semantics </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NUMQ = &quot;Num&quot;, &quot;(&quot;, LEVEL, &quot;,&quot;, LEVEL, &quot;)&quot;, COP, INTPN; </td>
   <td style="text-align:left;"> **number** **q**uery </td>
   <td style="text-align:left;"> levels must be hierarchically associated; first level determines semantics </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LABELALTERNATIVES = LABEL , { &quot;|&quot;, LABEL }; </td>
   <td style="text-align:left;"> **label alternatives** </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LABEL = LABELING | ( &quot;'&quot;, LABELING, &quot;'&quot; ); </td>
   <td style="text-align:left;"> **label** </td>
   <td style="text-align:left;"> levels must be part of the database structure; LABELING is an arbitrary character string or a label group class configured in the emuDB; result modifier # may only occur once </td>
  </tr>
  <tr>
   <td style="text-align:left;"> POSFCT = &quot;Start&quot; | &quot;Medial&quot; | &quot;End&quot;; </td>
   <td style="text-align:left;"> **pos**ition **f**un**ct**ion </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COP = &quot;=&quot; | &quot;==&quot; | &quot;!=&quot; | &quot;&gt;&quot; | &quot;&lt;&quot; | &quot;&lt;=&quot; | &quot;&gt;=&quot;; </td>
   <td style="text-align:left;"> **c**omparison **o**perator </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> INTPN = &quot;0&quot; | INTP; </td>
   <td style="text-align:left;"> **int**eger **p**ositive with **n**ull </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> INTP = DIGIT-&quot;0&quot;, { DIGIT }; </td>
   <td style="text-align:left;"> **int**eger **p**ositive </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DIGIT = &quot;0&quot; | &quot;1&quot; | &quot;2&quot; | &quot;3&quot; | &quot;4&quot; | &quot;5&quot; | &quot;6&quot; | &quot;7&quot; | &quot;8&quot; | &quot;9&quot;; </td>
   <td style="text-align:left;"> **digit** </td>
   <td style="text-align:left;">  </td>
  </tr>
</tbody>
</table>

**INFO:** The LABELING term used in the LABEL EBNF term can represent any character string that is present in the annotation. As this can be any combination of Unicode characters, we chose not to explicitly list them as part of the EBNF.

## Restrictions {#restrictions}

A query may only contain a single result modifier # (hashtag).


