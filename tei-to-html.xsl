<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="1.0">
    
    <!-- Identity template -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Root element -->
    <xsl:template match="tei:TEI">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>
                    <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
                </title>
                <!-- Bootstrap CSS -->
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
                <!-- Custom Styles -->
                <link rel="stylesheet" href="css/custom.css"/>
            </head>
            <body>
                <!-- Navigation bar -->
                <nav class="navbar navbar-expand-lg navbar-light bg-light">
                    <div class="container-fluid">
                        <a class="navbar-brand" href="#">Schomburgk Digital Edition</a>
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                            data-bs-target="#navbarNav">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarNav">
                            <ul class="navbar-nav">
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
                        </div>
                    </div>
                </nav>
                
                <!-- Main content -->
                <div class="container-fluid">
                    <div class="row">
                        <!-- Sidebar -->
                        <aside class="col-md-3">
                            <!-- Table of Contents -->
                            <div class="toc">
                                <h5>Contents</h5>
                                <ul>
                                    <xsl:apply-templates select="tei:text/tei:body//tei:head" mode="toc"/>
                                </ul>
                            </div>
                            <!-- Entity Filters -->
                            <div class="filters">
                                <h5>Filters</h5>
                                <label><input type="checkbox" id="filter-persons"/> Persons</label>
                                <br/>
                                <label><input type="checkbox" id="filter-places"/> Places</label>
                                <br/>
                                <label><input type="checkbox" id="filter-flora"/> Flora</label>
                                <br/>
                                <label><input type="checkbox" id="filter-fauna"/> Fauna</label>
                                <br/>
                                <label><input type="checkbox" id="filter-zoological"/> Zoological Names</label>
                            </div>
                            <!-- Index of Persons -->
                            <div class="index">
                                <h5>Index of Persons</h5>
                                <ul>
                                    <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person" mode="index-person"/>
                                </ul>
                            </div>
                        </aside>
                        
                        <!-- Main Text Area -->
                        <main class="col-md-9">
                            <!-- Page Indicator -->
                            <div class="page-indicator">Page <span id="current-page">1</span></div>
                            <!-- Text Content -->
                            <div id="text-content">
                                <xsl:apply-templates select="tei:text/tei:body"/>
                            </div>
                        </main>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="text-center">
                    <p>2023 Schomburgk Digital Edition Project</p>
                </footer>
                
                <!-- Scripts -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script src="js/main.js"></script>
            </body>
        </html>
    </xsl:template>
    
    <!-- Template for Table of Contents -->
    <xsl:template match="tei:head" mode="toc">
        <li>
            <a href="#section-{generate-id()}">
                <xsl:value-of select="normalize-space(.)"/>
            </a>
            <xsl:apply-templates select="following-sibling::*[1][self::tei:div]" mode="toc"/>
        </li>
    </xsl:template>
    
    <!-- Template for Index of Persons -->
    <xsl:template match="tei:person" mode="index-person">
        <li>
            <a href="#" class="index-person" data-id="{@xml:id}">
                <xsl:value-of select="tei:persName"/>
            </a>
        </li>
    </xsl:template>
    
    <!-- Transform divisions -->
    <xsl:template match="tei:div">
        <div id="section-{generate-id()}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Transform headings -->
    <xsl:template match="tei:head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    
    <!-- Transform paragraphs -->
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!-- Transform page breaks -->
    <xsl:template match="tei:pb">
        <div class="page-break" data-page="{@n}"></div>
        <script>
            document.getElementById('current-page').textContent = '<xsl:value-of select="@n"/>';
        </script>
    </xsl:template>
    
    <!-- Transform person names -->
    <xsl:template match="tei:persName">
        <span class="person-name" data-id="{@ref}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Transform place names -->
    <xsl:template match="tei:placeName">
        <span class="place-name" data-id="{@ref}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Transform flora names -->
    <xsl:template match="tei:name[@type = 'flora']">
        <span class="flora-name">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Transform fauna names -->
    <xsl:template match="tei:name[@type = 'fauna']">
        <span class="fauna-name">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Transform zoological names -->
    <xsl:template match="tei:name[@type = 'zoological']">
        <i class="zoological-name">
            <xsl:apply-templates/>
        </i>
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
    
    <!-- Default template for elements not explicitly handled -->
    <xsl:template match="tei:*">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
</xsl:stylesheet>
