<h1>Element type creators</h1>
Element type creators are helper functions to avoid a manual creation.
The file <b>poCreateElementType.m</b> from the parent directory may serve as an explanation:
<pre><code> file="../poCreateElementType.m"
</code></pre>
It calls the actual  element type creators stored in this subdirectory. Again, their code may be the best possible explanation. Don't be confused by the numerous checks at the beginning of each file.

<h2> Files in core/problemOperations/elementTypeCreators/</h2>


<h3> poCreateElementTypeFCMLine1d.m </h2>
<p>The one dimensional element for the Finite Cell Method (FCM).</p>
<pre><code> file="poCreateElementTypeFCMLine1d.m"
</code></pre>

<h3> poCreateElementTypeStandardLine1d.m </h2>
<p>The standard one dimensional element.</p>
<pre><code> file="poCreateElementTypeStandardLine1d.m"
</code></pre>

<h3> poCreateElementTypeStandardQuad2d.m </h2>
<p>The standard linear quad element.</p>
<pre><code> file="poCreateElementTypeStandardQuad2d.m"
</code></pre>

<h3> poCreateElementTypeStandardLine2d.m </h2>
<p>A line element to be used in two-dimensional problem, e.g. for load integration.</p>
<pre><code> file="poCreateElementTypeStandardLine2d.m"
</code></pre>

<h3> poCreateElementTypeStandardTruss2d.m </h2>
<p>A 2d truss element to be used in two-dimensional problem e.g. for truss systems.</p>
<pre><code> file="poCreateElementTypeStandardTruss2d.m"
</code></pre>

<h3> poCreateElementTypeStandardPoint2d.m </h2>
<p>A 2d point mass element to be used in two-dimensional problem.</p>
<pre><code> file="poCreateElementTypeStandardPoint2d.m"
</code></pre>

