<h1>Subelement type creators</h1>
Subelement type creators are helper functions to avoid a manual creation.
The file <b>poCreateSubelementType.m</b> from the parent directory may serve as an explanation:
<pre><code> file="../poCreateSubelementType.m"
</code></pre>
It calls the actual subelement type creators stored in this subdirectory. Again, their code may be the best possible explanation.

<h2> Files in core/problemOperations/subelementTypeCreators/</h2>

<h3> poCreateSubelementTypeLinearLine.m </h2>
<p>The standard one dimensional linear subelement.</p>
<pre><code> file="poCreateSubelementTypeLinearLine.m"
</code></pre>

<h3> poCreateSubelementTypeLinearQuad.m </h2>
<p>The standard linear quad subelement.</p>
<pre><code> file="poCreateSubelementTypeLinearQuad.m"
</code></pre>


<h3> poCreateSubelementTypeLegendreLine.m </h2>
<p>The standard one dimensional high-order subelement.</p>
<pre><code> file="poCreateSubelementTypeLegendreLine.m"
</code></pre>

<h3> poCreateSubelementTypeLegendreQuad.m </h2>
<p>The standard high-order quad subelement.</p>
<pre><code> file="poCreateSubelementTypeLegendreQuad.m"
</code></pre>



<h3> poCreateSubelementTypeLegendreEdge.m </h2>
<p>To be used as part of higher-dimensional elements (quads, hexes, etc.), does not contain nodal modes.</p>
<pre><code> file="poCreateSubelementTypeLegendreEdge.m"
</code></pre>
