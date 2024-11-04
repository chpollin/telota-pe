<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="2.0">

    <!-- Output method -->
    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="XSLT-compat"/>

    <!-- Keys for faster access -->
    <xsl:key name="person-by-id" match="tei:person" use="@xml:id"/>
    <xsl:key name="place-by-id" match="tei:place" use="@xml:id"/>
    <!-- Keys for flora, fauna, and zoological names -->
    <xsl:key name="flora-by-name" match="tei:name[@type='flora']" use="normalize-space(.)"/>
    <xsl:key name="fauna-by-name" match="tei:name[@type='fauna']" use="normalize-space(.)"/>
    <xsl:key name="zoological-by-name" match="tei:name[@type='zoological']" use="normalize-space(.)"/>

    <!-- Template for TEI root element -->
    <xsl:template match="tei:TEI">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
                </title>
                <!-- Metadata Improvements -->
                <meta name="description" content="Digital Edition of Schomburgk's Travels"/>
                <meta name="keywords" content="Schomburgk, South America, Travel Literature, Historical Text"/>
                <!-- Bootstrap CSS -->
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
                <!-- Bootstrap Icons CSS -->
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"/>
                <!-- Custom Styles -->
                <link rel="stylesheet" href="css/custom.css"/>
            </head>
            <body style="padding-top: 70px;">
                <!-- Navigation bar -->
                <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
                    <div class="container-fluid">
                        <a class="navbar-brand" href="#">Schomburgk Digital Edition</a>
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                            data-bs-target="#navbarNav">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarNav">
                            <ul class="navbar-nav me-auto">
                                <li class="nav-item active">
                                    <a class="nav-link" href="#">Text View</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Map View</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Search</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Analysis</a>
                                </li>
                            </ul>
                            <!-- Back to Top Button -->
                            <a href="#" class="btn btn-outline-secondary btn-sm back-to-top" id="back-to-top">Back to Top</a>
                        </div>
                    </div>
                </nav>

                <!-- Main content -->
                <div class="container-fluid">
                    <div class="row">
                        <!-- Sidebar -->
                        <aside class="col-md-3 sidebar-nav" style="position: sticky; top: 70px; height: calc(100vh - 70px); overflow-y: auto;">
                            <div>
                                <!-- Table of Contents -->
                                <div class="toc">
                                    <h5>Contents</h5>
                                    <ul class="nav flex-column">
                                        <xsl:apply-templates select="tei:text/tei:body//tei:head" mode="toc"/>
                                    </ul>
                                </div>
                                <!-- Indexes -->
                                <div class="indexes mt-3">
                                    <h5>Indexes</h5>
                                    <!-- Improved Indexes using Nav Tabs -->
                                    <ul class="nav nav-tabs" id="indexTabs" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="persons-tab" data-bs-toggle="tab" data-bs-target="#persons" type="button" role="tab" aria-controls="persons" aria-selected="true">Persons</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="places-tab" data-bs-toggle="tab" data-bs-target="#places" type="button" role="tab" aria-controls="places" aria-selected="false">Places</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="flora-tab" data-bs-toggle="tab" data-bs-target="#flora" type="button" role="tab" aria-controls="flora" aria-selected="false">Flora</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="fauna-tab" data-bs-toggle="tab" data-bs-target="#fauna" type="button" role="tab" aria-controls="fauna" aria-selected="false">Fauna</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="zoological-tab" data-bs-toggle="tab" data-bs-target="#zoological" type="button" role="tab" aria-controls="zoological" aria-selected="false">Zoological Names</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="indexTabsContent">
                                        <!-- Index of Persons -->
                                        <div class="tab-pane fade show active" id="persons" role="tabpanel" aria-labelledby="persons-tab">
                                            <ul class="list-unstyled mt-2">
                                                <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person" mode="index-person"/>
                                            </ul>
                                        </div>
                                        <!-- Index of Places -->
                                        <div class="tab-pane fade" id="places" role="tabpanel" aria-labelledby="places-tab">
                                            <ul class="list-unstyled mt-2">
                                                <xsl:apply-templates select="tei:listPlace/tei:place" mode="index-place"/>
                                            </ul>
                                        </div>
                                        <!-- Index of Flora -->
                                        <div class="tab-pane fade" id="flora" role="tabpanel" aria-labelledby="flora-tab">
                                            <ul class="list-unstyled mt-2">
                                                <xsl:apply-templates select="distinct-values(//tei:name[@type='flora']/normalize-space(.))" mode="index-flora"/>
                                            </ul>
                                        </div>
                                        <!-- Index of Fauna -->
                                        <div class="tab-pane fade" id="fauna" role="tabpanel" aria-labelledby="fauna-tab">
                                            <ul class="list-unstyled mt-2">
                                                <xsl:apply-templates select="distinct-values(//tei:name[@type='fauna']/normalize-space(.))" mode="index-fauna"/>
                                            </ul>
                                        </div>
                                        <!-- Index of Zoological Names -->
                                        <div class="tab-pane fade" id="zoological" role="tabpanel" aria-labelledby="zoological-tab">
                                            <ul class="list-unstyled mt-2">
                                                <xsl:apply-templates select="distinct-values(//tei:name[@type='zoological']/normalize-space(.))" mode="index-zoological"/>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        <!-- Main Text Area -->
                        <main class="col-md-9 main-content">
                            <!-- Text Content -->
                            <div id="text-content">
                                <xsl:apply-templates select="tei:text/tei:body"/>
                            </div>

                            <!-- Entity Entries -->
                            <div id="entity-entries">
                                <!-- Person Entries -->
                                <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person" mode="person-entry"/>
                                <!-- Place Entries -->
                                <xsl:apply-templates select="tei:listPlace/tei:place" mode="place-entry"/>
                                <!-- Flora Entries -->
                                <xsl:apply-templates select="distinct-values(//tei:name[@type='flora']/normalize-space(.))" mode="flora-entry"/>
                                <!-- Fauna Entries -->
                                <xsl:apply-templates select="distinct-values(//tei:name[@type='fauna']/normalize-space(.))" mode="fauna-entry"/>
                                <!-- Zoological Entries -->
                                <xsl:apply-templates select="distinct-values(//tei:name[@type='zoological']/normalize-space(.))" mode="zoological-entry"/>
                            </div>
                        </main>
                    </div>
                </div>

                <!-- Footer -->
                <footer class="text-center">
                    <p>2023 Schomburgk Digital Edition Project</p>
                </footer>

                <!-- JavaScript Libraries -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

                <!-- Custom JavaScript -->
                <script>
                document.addEventListener('DOMContentLoaded', function() {
                    // Back to Top Button
                    var backToTopButton = document.getElementById('back-to-top');
                    backToTopButton.addEventListener('click', function(e) {
                        e.preventDefault();
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    });

                    // Show/hide back to top button
                    window.addEventListener('scroll', () => {
                        const backToTop = document.getElementById('back-to-top');
                        if (window.scrollY > 300) {
                            backToTop.style.opacity = '1';
                        } else {
                            backToTop.style.opacity = '0';
                        }
                    });

                    // Smooth scrolling for anchor links
                    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                        anchor.addEventListener('click', function (e) {
                            e.preventDefault();
                            const target = document.querySelector(this.getAttribute('href'));
                            if (target) {
                                target.scrollIntoView({
                                    behavior: 'smooth',
                                    block: 'start'
                                });
                            }
                        });
                    });

                    // Active Section Highlighting
                    var tocLinks = document.querySelectorAll('.toc a');
                    var sections = document.querySelectorAll('div[id^="section-"]');
                    var options = {
                        rootMargin: '0px 0px -80% 0px',
                        threshold: 0
                    };
                    var observer = new IntersectionObserver(function(entries, observer) {
                        entries.forEach(function(entry) {
                            if (entry.isIntersecting) {
                                var id = entry.target.getAttribute('id');
                                tocLinks.forEach(function(link) {
                                    link.classList.toggle('active', link.getAttribute('href') === '#' + id);
                                });
                            }
                        });
                    }, options);
                    sections.forEach(function(section) {
                        observer.observe(section);
                    });

                    // Tooltips for Entities
                    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                        return new bootstrap.Tooltip(tooltipTriggerEl);
                    });
                });
                </script>
            </body>
        </html>
    </xsl:template>

    <!-- Template for Table of Contents -->
    <xsl:template match="tei:head" mode="toc">
        <li class="nav-item">
            <a class="nav-link" href="#section-{generate-id(..)}">
                <xsl:value-of select="normalize-space(.)"/>
            </a>
        </li>
    </xsl:template>

    <!-- Template for Index of Persons -->
    <xsl:template match="tei:person" mode="index-person">
        <li>
            <a href="#person-{@xml:id}" class="index-link" data-type="person">
                <i class="bi bi-person-fill"></i>
                <xsl:value-of select="tei:persName"/>
            </a>
        </li>
    </xsl:template>

    <!-- Template for Index of Places -->
    <xsl:template match="tei:place" mode="index-place">
        <li>
            <a href="#place-{@xml:id}" class="index-link" data-type="place">
                <i class="bi bi-geo-alt-fill"></i>
                <xsl:value-of select="tei:placeName"/>
            </a>
        </li>
    </xsl:template>

    <!-- Template for Index of Flora -->
    <xsl:template match="*" mode="index-flora">
        <xsl:param name="name" select="."/>
        <li>
            <a href="#flora-{generate-id()}" class="index-link" data-type="flora">
                <i class="bi bi-flower1"></i>
                <xsl:value-of select="$name"/>
            </a>
        </li>
    </xsl:template>

    <!-- Template for Index of Fauna -->
    <xsl:template match="*" mode="index-fauna">
        <xsl:param name="name" select="."/>
        <li>
            <a href="#fauna-{generate-id()}" class="index-link" data-type="fauna">
                <i class="bi bi-bug-fill"></i>
                <xsl:value-of select="$name"/>
            </a>
        </li>
    </xsl:template>

    <!-- Template for Index of Zoological Names -->
    <xsl:template match="*" mode="index-zoological">
        <xsl:param name="name" select="."/>
        <li>
            <a href="#zoological-{generate-id()}" class="index-link" data-type="zoological">
                <i class="bi bi-book-half"></i>
                <xsl:value-of select="$name"/>
            </a>
        </li>
    </xsl:template>

    <!-- Transform divisions -->
    <xsl:template match="tei:div">
        <div id="section-{generate-id()}" class="section">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Transform headings -->
    <xsl:template match="tei:head">
        <h2 class="section-title">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- Transform paragraphs -->
    <xsl:template match="tei:p">
        <p class="text-paragraph">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Transform page breaks -->
    <xsl:template match="tei:pb">
        <div class="page-break" data-page="{@n}">
            <span class="page-number">Page <xsl:value-of select="@n"/></span>
        </div>
    </xsl:template>

    <!-- Transform person names -->
    <xsl:template match="tei:persName">
        <xsl:variable name="person-id" select="substring-after(@ref, '#')"/>
        <xsl:variable name="person" select="key('person-by-id', $person-id)"/>
        <a href="#person-{$person-id}" class="person-name entity-link" data-bs-toggle="tooltip" data-bs-placement="top" title="{normalize-space($person/tei:note)}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- Transform place names -->
    <xsl:template match="tei:placeName">
        <xsl:variable name="place-id" select="substring-after(@ref, '#')"/>
        <xsl:variable name="place" select="key('place-by-id', $place-id)"/>
        <xsl:choose>
            <xsl:when test="$place">
                <a href="#place-{$place-id}" class="place-name entity-link" data-bs-toggle="tooltip" data-bs-placement="top" title="{normalize-space($place/tei:note)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span class="place-name">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Transform flora names -->
    <xsl:template match="tei:name[@type = 'flora']">
        <xsl:variable name="flora-name" select="normalize-space(.)"/>
        <a href="#flora-{generate-id()}" class="flora-name entity-link" data-bs-toggle="tooltip" data-bs-placement="top" title="Flora">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <!-- Transform fauna names -->
    <xsl:template match="tei:name[@type = 'fauna']">
        <xsl:variable name="fauna-name" select="normalize-space(.)"/>
        <a href="#fauna-{generate-id()}" class="fauna-name entity-link" data-bs-toggle="tooltip" data-bs-placement="top" title="Fauna">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <!-- Transform zoological names -->
    <xsl:template match="tei:name[@type = 'zoological']">
        <xsl:variable name="zoological-name" select="normalize-space(.)"/>
        <a href="#zoological-{generate-id()}" class="zoological-name entity-link" data-bs-toggle="tooltip" data-bs-placement="top" title="Zoological Name">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <!-- Transform foreign words -->
    <xsl:template match="tei:foreign">
        <span class="foreign-word" lang="{@xml:lang}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Transform hi elements -->
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'superscript'">
                <sup>
                    <xsl:apply-templates/>
                </sup>
            </xsl:when>
            <xsl:when test="@rend = 'bold'">
                <strong>
                    <xsl:apply-templates/>
                </strong>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Transform lists -->
    <xsl:template match="tei:list">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <!-- Transform list items -->
    <xsl:template match="tei:item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!-- Transform terms -->
    <xsl:template match="tei:term">
        <span class="term">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Transform notes -->
    <xsl:template match="tei:note">
        <span class="footnote" id="{@xml:id}">
            <sup>*</sup>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Transform quotes -->
    <xsl:template match="tei:q">
        <q>
            <xsl:apply-templates/>
        </q>
    </xsl:template>

    <!-- Transform person entries in listPerson -->
    <xsl:template match="tei:person" mode="person-entry">
        <div id="person-{@xml:id}" class="person-entry card mb-3">
            <div class="card-header">
                <h3 class="card-title"><i class="bi bi-person-fill"></i> <xsl:value-of select="tei:persName"/></h3>
            </div>
            <div class="card-body">
                <xsl:if test="tei:birth/@when">
                    <p><strong>Birth:</strong> <xsl:value-of select="tei:birth/@when"/></p>
                </xsl:if>
                <xsl:if test="tei:death/@when">
                    <p><strong>Death:</strong> <xsl:value-of select="tei:death/@when"/></p>
                </xsl:if>
                <xsl:if test="tei:occupation">
                    <p><strong>Occupation:</strong> <xsl:value-of select="normalize-space(tei:occupation)"/></p>
                </xsl:if>
                <xsl:if test="tei:note">
                    <p><strong>Note:</strong> <xsl:value-of select="normalize-space(tei:note)"/></p>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <!-- Transform place entries in listPlace -->
    <xsl:template match="tei:place" mode="place-entry">
        <div id="place-{@xml:id}" class="place-entry card mb-3">
            <div class="card-header">
                <h3 class="card-title"><i class="bi bi-geo-alt-fill"></i> <xsl:value-of select="tei:placeName"/></h3>
            </div>
            <div class="card-body">
                <xsl:if test="tei:location/tei:geo">
                    <p><strong>Coordinates:</strong> <xsl:value-of select="tei:location/tei:geo"/></p>
                </xsl:if>
                <xsl:if test="tei:note">
                    <p><strong>Note:</strong> <xsl:value-of select="normalize-space(tei:note)"/></p>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <!-- Transform flora entries -->
    <xsl:template match="*" mode="flora-entry">
        <xsl:param name="name" select="."/>
        <div id="flora-{generate-id()}" class="flora-entry card mb-3">
            <div class="card-header">
                <h3 class="card-title"><i class="bi bi-flower1"></i> <xsl:value-of select="$name"/></h3>
            </div>
            <div class="card-body">
                <p>No additional information available.</p>
            </div>
        </div>
    </xsl:template>

    <!-- Transform fauna entries -->
    <xsl:template match="*" mode="fauna-entry">
        <xsl:param name="name" select="."/>
        <div id="fauna-{generate-id()}" class="fauna-entry card mb-3">
            <div class="card-header">
                <h3 class="card-title"><i class="bi bi-bug-fill"></i> <xsl:value-of select="$name"/></h3>
            </div>
            <div class="card-body">
                <p>No additional information available.</p>
            </div>
        </div>
    </xsl:template>

    <!-- Transform zoological entries -->
    <xsl:template match="*" mode="zoological-entry">
        <xsl:param name="name" select="."/>
        <div id="zoological-{generate-id()}" class="zoological-entry card mb-3">
            <div class="card-header">
                <h3 class="card-title"><i class="bi bi-book-half"></i> <xsl:value-of select="$name"/></h3>
            </div>
            <div class="card-body">
                <p>Scientific name of species.</p>
            </div>
        </div>
    </xsl:template>

    <!-- Default template for elements not explicitly handled -->
    <xsl:template match="tei:*">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

</xsl:stylesheet>
