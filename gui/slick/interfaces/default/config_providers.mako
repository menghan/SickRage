<%!
    import sickbeard
    from sickbeard.providers.generic import GenericProvider
    from sickbeard.providers import thepiratebay
    from sickbeard.helpers import anon_url

    global title="Config - Providers"
    global header="Search Providers"


    global topmenu="config"
    import os.path
    include os.path.join(sickbeard.PROG_DIR, "gui/slick/interfaces/default/inc_top.mako")
%>
% if not header is UNDEFINED:
    <h1 class="header">${header}</h1>
% else
    <h1 class="title">${title}</h1>
% endif
<script type="text/javascript" src="${sbRoot}/js/configProviders.js?${sbPID}"></script>
<script type="text/javascript" src="${sbRoot}/js/config.js?${sbPID}"></script>
% if sickbeard.USE_NZBS
<script type="text/javascript" charset="utf-8">
<!--
$(document).ready(function(){
var show_nzb_providers = % if sickbeard.USE_NZBS then "true" else "false"#;
% for curNewznabProvider in sickbeard.newznabProviderList:
$(this).addProvider('$curNewznabProvider.getID()', '$curNewznabProvider.name', '$curNewznabProvider.url', '$curNewznabProvider.key', '$curNewznabProvider.catIDs', $int($curNewznabProvider.default), show_nzb_providers);
% endfor
});
//-->
</script>
% endif

% if sickbeard.USE_TORRENTS
<script type="text/javascript" charset="utf-8">
<!--
$(document).ready(function(){
% for curTorrentRssProvider in sickbeard.torrentRssProviderList:
    $(this).addTorrentRssProvider('$curTorrentRssProvider.getID()', '$curTorrentRssProvider.name', '$curTorrentRssProvider.url', '$curTorrentRssProvider.cookies', '$curTorrentRssProvider.titleTAG');
% endfor
});
//-->
</script>
% endif

<div id="config">
    <div id="config-content">

        <form id="configForm" action="saveProviders" method="post">

            <div id="config-components">
                <ul>
                    <li><a href="#core-component-group1">Provider Priorities</a></li>
                    <li><a href="#core-component-group2">Provider Options</a></li>
                  % if sickbeard.USE_NZBS
                    <li><a href="#core-component-group3">Configure Custom Newznab Providers</a></li>
                  % endif
                  % if sickbeard.USE_TORRENTS
                    <li><a href="#core-component-group4">Configure Custom Torrent Providers</a></li>
                  % endif
                </ul>

                <div id="core-component-group1" class="component-group" style='min-height: 550px;'>

                    <div class="component-group-desc">
                        <h3>Provider Priorities</h3>
                        <p>Check off and drag the providers into the order you want them to be used.</p>
                        <p>At least one provider is required but two are recommended.</p>

                        % if not sickbeard.USE_NZBS or not sickbeard.USE_TORRENTS:
                        <blockquote style="margin: 20px 0;">NZB/Torrent providers can be toggled in <b><a href="${sbRoot}/config/search">Search Settings</a></b></blockquote>
                        % else:
                        <br/>
                        % endif

                        <div>
                            <p class="note">* Provider does not support backlog searches at this time.</p>
                            <p class="note">** Provider supports <b>limited</b> backlog searches, all episodes/qualities may not be available.</p>
                            <p class="note">! Provider is <b>NOT WORKING</b>.</p>
                        </div>
                    </div>

                    <fieldset class="component-group-list">
                        <ul id="provider_order_list">
                        % for curProvider in sickbeard.providers.sortedProviderList():
                            % if curProvider.providerType == GenericProvider.NZB and not sickbeard.USE_NZBS:
                                % continue
                            % elif curProvider.providerType == GenericProvider.TORRENT and not sickbeard.USE_TORRENTS:
                                % continue
                            % endif
                            % curName = curProvider.getID()
                          <li class="ui-state-default" id="$curName">
                            <input type="checkbox" id="enable_$curName" class="provider_enabler" % if curProvider.isEnabled() then "checked=\"checked\"" else ""#/>
                            <a href="<%= anon_url(curProvider.url) %>" class="imgLink" rel="noreferrer" onclick="window.open(this.href, '_blank'); return false;"><img src="$sbRoot/images/providers/$curProvider.imageName()" alt="$curProvider.name" title="$curProvider.name" width="16" height="16" style="vertical-align:middle;"/></a>
                            <span style="vertical-align:middle;">$curProvider.name</span>
                            % if not curProvider.supportsBacklog then "*" else ""
                            % if $curProvider.name == "EZRSS" then "**" else ""
                            <span class="ui-icon ui-icon-arrowthick-2-n-s pull-right" style="vertical-align:middle;"></span>
                          </li>
                        #end for
                        </ul>
                        <input type="hidden" name="provider_order" id="provider_order" value="<%=" ".join([x.getID()+':'+str(int(x.isEnabled())) for x in sickbeard.providers.sortedProviderList()])%>"/>
                        <br/><input type="submit" class="btn config_submitter" value="Save Changes" /><br/>
                    </fieldset>
                </div><!-- /component-group1 //-->

                <div id="core-component-group2" class="component-group">

                    <div class="component-group-desc">
                        <h3>Provider Options</h3>
                        <p>Configure individual provider settings here.</p>
                        <p>Check with provider's website on how to obtain an API key if needed.</p>
                    </div>

                    <fieldset class="component-group-list">
                        <div class="field-pair">
                            <label for="editAProvider" id="provider-list">
                                <span class="component-title">Configure provider:</span>
                                <span class="component-desc">
                                    <%
                                        provider_config_list = []
                                        for curProvider in sickbeard.providers.sortedProviderList():
                                            if curProvider.providerType == GenericProvider.NZB and (not sickbeard.USE_NZBS or not curProvider.isEnabled()):
                                                continue
                                            elif curProvider.providerType == GenericProvider.TORRENT and ( not sickbeard.USE_TORRENTS or not curProvider.isEnabled()):
                                                continue
                                            endif
                                            provider_config_list.append(curProvider)
                                        endfor
                                    %>
                                    % if provider_config_list:
                                        <select id="editAProvider" class="form-control input-sm">
                                            % for cur_provider in provider_config_list:
                                                <option value="${cur_provider.getID()}">${cur_provider.name}</option>
                                            % endfor
                                        </select>
                                    % else:
                                        No providers available to configure.
                                    % endif
                                </span>
                            </label>
                        </div>


                    <!-- start div for editing providers //-->
                    % for curNewznabProvider in [curProvider for curProvider in sickbeard.newznabProviderList]:
                    <div class="providerDiv" id="${curNewznabProvider.getID()}Div">
                        % if curNewznabProvider.default and curNewznabProvider.needs_auth
                        <div class="field-pair">
                            <label for="${curNewznabProvider.getID()}_url">
                                <span class="component-title">URL:</span>
                                <span class="component-desc">
                                    <input type="text" id="${curNewznabProvider.getID()}_url" value="${curNewznabProvider.url}" class="form-control input-sm input350" disabled/>
                                </span>
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="${curNewznabProvider.getID()}_hash">
                                <span class="component-title">API key:</span>
                                <span class="component-desc">
                                    <input type="text" id="${curNewznabProvider.getID()}_hash" value="${curNewznabProvider.key}" newznab_name="${curNewznabProvider.getID()}_hash" class="newznab_key form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNewznabProvider, 'enable_daily'):
                        <div class="field-pair">
                            <label for="${curNewznabProvider.getID()}_enable_daily">
                                <span class="component-title">Enable daily searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNewznabProvider.getID()}_enable_daily" id="${curNewznabProvider.getID()}_enable_daily" % if curNewznabProvider.enable_daily then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform daily searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNewznabProvider, 'enable_backlog'):
                        <div class="field-pair">
                            <label for="${curNewznabProvider.getID()}_enable_backlog">
                                <span class="component-title">Enable backlog searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNewznabProvider.getID()}_enable_backlog" id="${curNewznabProvider.getID()}_enable_backlog" % if curNewznabProvider.enable_backlog then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform backlog searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNewznabProvider, 'search_fallback'):
                        <div class="field-pair">
                            <label for="${curNewznabProvider.getID()}_search_fallback">
                                <span class="component-title">Season search fallback</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNewznabProvider.getID()}_search_fallback" id="${curNewznabProvider.getID()}_search_fallback" % if curNewznabProvider.search_fallback then "checked=\"checked\"" else ""#/>
                                    <p>when searching for a complete season depending on search mode you may return no results, this helps by restarting the search using the opposite search mode.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if $hasattr(curNewznabProvider, 'search_mode'):
                        <div class="field-pair">
                            <label>
                                <span class="component-title">Season search mode</span>
                                <span class="component-desc">
                                    <p>when searching for complete seasons you can choose to have it look for season packs only, or choose to have it build a complete season from just single episodes.</p>
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curNewznabProvider.getID()}_search_mode" id="${curNewznabProvider.getID()}_search_mode_sponly" value="sponly" % if curNewznabProvider.search_mode=="sponly" then "checked=\"checked\"" else ""# />season packs only.
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curNewznabProvider.getID()}_search_mode" id="${curNewznabProvider.getID()}_search_mode_eponly" value="eponly" % if curNewznabProvider.search_mode=="eponly" then "checked=\"checked\"" else ""# />episodes only.
                                </span>
                            </label>
                        </div>
                        % endif

                    </div>
                    % endfor

                    % for curNzbProvider in [curProvider for curProvider in sickbeard.providers.sortedProviderList() if curProvider.providerType == GenericProvider.NZB and curProvider not in sickbeard.newznabProviderList]:
                    <div class="providerDiv" id="${curNzbProvider.getID()}Div">
                        % if hasattr(curNzbProvider, 'username'):
                        <div class="field-pair">
                            <label for="${curNzbProvider.getID()}_username">
                                <span class="component-title">Username:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curNzbProvider.getID()}_username" value="${curNzbProvider.username}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNzbProvider, 'api_key'):
                        <div class="field-pair">
                            <label for="${curNzbProvider.getID()}_api_key">
                                <span class="component-title">API key:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curNzbProvider.getID()}_api_key" value="${curNzbProvider.api_key}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif


                        % if hasattr(curNzbProvider, 'enable_daily'):
                        <div class="field-pair">
                            <label for="${curNzbProvider.getID()}_enable_daily">
                                <span class="component-title">Enable daily searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNzbProvider.getID()}_enable_daily" id="${curNzbProvider.getID()}_enable_daily" % if curNzbProvider.enable_daily then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform daily searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNzbProvider, 'enable_backlog'):
                        <div class="field-pair">
                            <label for="${curNzbProvider.getID()}_enable_backlog">
                                <span class="component-title">Enable backlog searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNzbProvider.getID()}_enable_backlog" id="${curNzbProvider.getID()}_enable_backlog" % if curNzbProvider.enable_backlog then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform backlog searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNzbProvider, 'search_fallback'):
                        <div class="field-pair">
                            <label for="${curNzbProvider.getID()}_search_fallback">
                                <span class="component-title">Season search fallback</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curNzbProvider.getID()}_search_fallback" id="${curNzbProvider.getID()}_search_fallback" % if curNzbProvider.search_fallback then "checked=\"checked\"" else ""#/>
                                    <p>when searching for a complete season depending on search mode you may return no results, this helps by restarting the search using the opposite search mode.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curNzbProvider, 'search_mode'):
                        <div class="field-pair">
                            <label>
                                <span class="component-title">Season search mode</span>
                                <span class="component-desc">
                                    <p>when searching for complete seasons you can choose to have it look for season packs only, or choose to have it build a complete season from just single episodes.</p>
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curNzbProvider.getID()}_search_mode" id="${curNzbProvider.getID()}_search_mode_sponly" value="sponly" % if curNzbProvider.search_mode=="sponly" then "checked=\"checked\"" else ""# />season packs only.
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curNzbProvider.getID()}_search_mode" id="${curNzbProvider.getID()}_search_mode_eponly" value="eponly" % if curNzbProvider.search_mode=="eponly" then "checked=\"checked\"" else ""# />episodes only.
                                </span>
                            </label>
                        </div>
                        % endif

                    </div>
                    % endfor

                    % for curTorrentProvider in [curProvider for curProvider in sickbeard.providers.sortedProviderList() if curProvider.providerType == GenericProvider.TORRENT]:
                    <div class="providerDiv" id="${curTorrentProvider.getID()}Div">
                        % if hasattr(curTorrentProvider, 'api_key'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_api_key">
                                <span class="component-title">Api key:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curTorrentProvider.getID()}_api_key" id="${curTorrentProvider.getID()}_api_key" value="${curTorrentProvider.api_key}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'digest'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_digest">
                                <span class="component-title">Digest:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curTorrentProvider.getID()}_digest" id="${curTorrentProvider.getID()}_digest" value="${curTorrentProvider.digest}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'hash'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_hash">
                                <span class="component-title">Hash:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curTorrentProvider.getID()}_hash" id="${curTorrentProvider.getID()}_hash" value="${curTorrentProvider.hash}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'username'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_username">
                                <span class="component-title">Username:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curTorrentProvider.getID()}_username" id="${curTorrentProvider.getID()}_username" value="${curTorrentProvider.username}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'password'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_password">
                                <span class="component-title">Password:</span>
                                <span class="component-desc">
                                    <input type="password" name="${curTorrentProvider.getID()}_password" id="${curTorrentProvider.getID()}_password" value="${curTorrentProvider.password}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'passkey'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_passkey">
                                <span class="component-title">Passkey:</span>
                                <span class="component-desc">
                                    <input type="text" name="${curTorrentProvider.getID()}_passkey" id="${curTorrentProvider.getID()}_passkey" value="${curTorrentProvider.passkey}" class="form-control input-sm input350" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'ratio'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_ratio">
                                <span class="component-title" id="${curTorrentProvider.getID()}_ratio_desc">Seed ratio:</span>
                                <span class="component-desc">
                                    <input type="number" step="0.1" name="${curTorrentProvider.getID()}_ratio" id="${curTorrentProvider.getID()}_ratio" value="${curTorrentProvider.ratio}" class="form-control input-sm input75" />
                                </span>
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc">
                                    <p>stop transfer when ratio is reached<br>(-1 SickRage default to seed forever, or leave blank for downloader default)</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'minseed'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_minseed">
                                <span class="component-title" id="${curTorrentProvider.getID()}_minseed_desc">Minimum seeders:</span>
                                <span class="component-desc">
                                    <input type="number" name="${curTorrentProvider.getID()}_minseed" id="${curTorrentProvider.getID()}_minseed" value="${curTorrentProvider.minseed}" class="form-control input-sm input75" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'minleech'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_minleech">
                                <span class="component-title" id="${curTorrentProvider.getID()}_minleech_desc">Minimum leechers:</span>
                                <span class="component-desc">
                                    <input type="number" name="${curTorrentProvider.getID()}_minleech" id="${curTorrentProvider.getID()}_minleech" value="${curTorrentProvider.minleech}" class="form-control input-sm input75" />
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'confirmed'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_confirmed">
                                <span class="component-title">Confirmed download</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_confirmed" id="${curTorrentProvider.getID()}_confirmed" % if curTorrentProvider.confirmed then "checked=\"checked\"" else ""#/>
                                    <p>only download torrents from trusted or verified uploaders ?</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'ranked'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_ranked">
                                <span class="component-title">Ranked torrents</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_ranked" id="${curTorrentProvider.getID()}_ranked" % if curTorrentProvider.ranked then "checked=\"checked\"" else ""#/>
                                    <p>only download ranked torrents (internal releases)</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'sorting'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_sorting">
                                <span class="component-title">Sorting results by</span>
                                <span class="component-desc">
                                    <select name="${curTorrentProvider.getID()}_sorting" id="${curTorrentProvider.getID()}_sorting" class="form-control input-sm">
% for curAction in ('last', 'seeders', 'leechers'):
    <option value="${curAction}" % if curAction == $curTorrentProvider.sorting then ' selected="selected"' else ''#>${curAction}</option>
% endfor
                                    </select>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'proxy'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_proxy">
                                <span class="component-title">Access provider via proxy</span>
                                <span class="component-desc">
                                    <input type="checkbox" class="enabler" name="${curTorrentProvider.getID()}_proxy" id="${curTorrentProvider.getID()}_proxy" % if curTorrentProvider.proxy.enabled then "checked=\"checked\"" else ""#/>
                                    <p>to bypass country blocking mechanisms</p>
                                </span>
                            </label>
                        </div>

                        % if hasattr(curTorrentProvider.proxy, 'url'):
                        <div class="field-pair content_${curTorrentProvider.getID()}_proxy" id="content_${curTorrentProvider.getID()}_proxy">
                            <label for="${curTorrentProvider.getID()}_proxy_url">
                                <span class="component-title">Proxy URL:</span>
                                <span class="component-desc">
                                  <select name="${curTorrentProvider.getID()}_proxy_url" id="${curTorrentProvider.getID()}_proxy_url" class="form-control input-sm">
                                    % for i in curTorrentProvider.proxy.urls.keys():
                                    <option value="${curTorrentProvider.proxy.urls[i]}" % if curTorrentProvider.proxy.urls[$i] == $curTorrentProvider.proxy.url then "selected=\"selected\"" else ""#>$i</option>
                                    % endfor
                                    </select>
                                </span>
                            </label>
                        </div>
                        % endif
                        % endif

                        % if hasattr(curTorrentProvider, 'freeleech'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_freeleech">
                                <span class="component-title">Freeleech</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_freeleech" id="${curTorrentProvider.getID()}_freeleech" % if curTorrentProvider.freeleech then "checked=\"checked\"" else ""#/>
                                    <p>only download <b>[FreeLeech]</b> torrents.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'enable_daily'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_enable_daily">
                                <span class="component-title">Enable daily searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_enable_daily" id="${curTorrentProvider.getID()}_enable_daily" % if curTorrentProvider.enable_daily then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform daily searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'enable_backlog'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_enable_backlog">
                                <span class="component-title">Enable backlog searches</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_enable_backlog" id="${curTorrentProvider.getID()}_enable_backlog" % if curTorrentProvider.enable_backlog then "checked=\"checked\"" else ""#/>
                                    <p>enable provider to perform backlog searches.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'search_fallback'):
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_search_fallback">
                                <span class="component-title">Season search fallback</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_search_fallback" id="${curTorrentProvider.getID()}_search_fallback" % if curTorrentProvider.search_fallback then "checked=\"checked\"" else ""#/>
                                    <p>when searching for a complete season depending on search mode you may return no results, this helps by restarting the search using the opposite search mode.</p>
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'search_mode'):
                        <div class="field-pair">
                            <label>
                                <span class="component-title">Season search mode</span>
                                <span class="component-desc">
                                    <p>when searching for complete seasons you can choose to have it look for season packs only, or choose to have it build a complete season from just single episodes.</p>
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curTorrentProvider.getID()}_search_mode" id="${curTorrentProvider.getID()}_search_mode_sponly" value="sponly" % if curTorrentProvider.search_mode=="sponly" then "checked=\"checked\"" else ""# />season packs only.
                                </span>
                            </label>
                            <label>
                                <span class="component-title"></span>
                                <span class="component-desc">
                                    <input type="radio" name="${curTorrentProvider.getID()}_search_mode" id="${curTorrentProvider.getID()}_search_mode_eponly" value="eponly" % if curTorrentProvider.search_mode=="eponly" then "checked=\"checked\"" else ""# />episodes only.
                                </span>
                            </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'cat') and curTorrentProvider.getID() == 'tntvillage':
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_cat">
                                <span class="component-title">Category:</span>
                                <span class="component-desc">
                                    <select name="${curTorrentProvider.getID()}_cat" id="${curTorrentProvider.getID()}_cat" class="form-control input-sm">
                                        #for $i in $curTorrentProvider.category_dict.keys():
                                        <option value="$curTorrentProvider.category_dict[$i]" % if curTorrentProvider.category_dict[$i] == $curTorrentProvider.cat then "selected=\"selected\"" else ""#>$i</option>
                                        #end for
                                    </select>
                                </span>
                           </label>
                        </div>
                        % endif

                        % if hasattr(curTorrentProvider, 'subtitle') and curTorrentProvider.getID() == 'tntvillage':
                        <div class="field-pair">
                            <label for="${curTorrentProvider.getID()}_subtitle">
                                <span class="component-title">Subtitled</span>
                                <span class="component-desc">
                                    <input type="checkbox" name="${curTorrentProvider.getID()}_subtitle" id="${curTorrentProvider.getID()}_subtitle" % if curTorrentProvider.subtitle then "checked=\"checked\"" else ""#/>
                                    <p>select torrent with Italian subtitle</p>
                                </span>
                            </label>
                        </div>
                        % endif

                    </div>
                    % endfor


                    <!-- end div for editing providers -->

                    <input type="submit" class="btn config_submitter" value="Save Changes" /><br/>

                    </fieldset>
                </div><!-- /component-group2 //-->

                % if sickbeard.USE_NZBS
                <div id="core-component-group3" class="component-group">

                    <div class="component-group-desc">
                        <h3>Configure Custom<br />Newznab Providers</h3>
                        <p>Add and setup or remove custom Newznab providers.</p>
                    </div>

                    <fieldset class="component-group-list">
                        <div class="field-pair">
                            <label for="newznab_string">
                                <span class="component-title">Select provider:</span>
                                <span class="component-desc">
                                    <input type="hidden" name="newznab_string" id="newznab_string" />
                                    <select id="editANewznabProvider" class="form-control input-sm">
                                        <option value="addNewznab">-- add new provider --</option>
                                    </select>
                                </span>
                            </label>
                        </div>

                    <div class="newznabProviderDiv" id="addNewznab">
                        <div class="field-pair">
                            <label for="newznab_name">
                                <span class="component-title">Provider name:</span>
                                <input type="text" id="newznab_name" class="form-control input-sm input200" />
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="newznab_url">
                                <span class="component-title">Site URL:</span>
                                <input type="text" id="newznab_url" class="form-control input-sm input350" />
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="newznab_key">
                                <span class="component-title">API key:</span>
                                <input type="text" id="newznab_key" class="form-control input-sm input350" />
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc">(if not required, type 0)</span>
                            </label>
                        </div>

                        <div class="field-pair" id="newznabcapdiv">
                            <label>
                                <span class="component-title">Newznab search categories:</span>
                                <select id="newznab_cap" multiple="multiple" style="min-width:10em;" ></select>
                                <select id="newznab_cat" multiple="multiple" style="min-width:10em;" ></select>
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc">(select your Newznab categories on the left, and click the "update categories" button to use them for searching.) <b>don't forget to to save the form!</b></span>
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc"><input class="btn" type="button" class="newznab_cat_update" id="newznab_cat_update" value="Update Categories" />
                                    <span class="updating_categories"></span>
                                </span>
                            </label>
                        </div>

                        <div id="newznab_add_div">
                            <input class="btn" type="button" class="newznab_save" id="newznab_add" value="Add" />
                        </div>
                        <div id="newznab_update_div" style="display: none;">
                            <input class="btn btn-danger newznab_delete" type="button" class="newznab_delete" id="newznab_delete" value="Delete" />
                        </div>
                    </div>

                    </fieldset>
                </div><!-- /component-group3 //-->
                % endif

                % if sickbeard.USE_TORRENTS:

                <div id="core-component-group4" class="component-group">

                <div class="component-group-desc">
                    <h3>Configure Custom Torrent Providers</h3>
                    <p>Add and setup or remove custom RSS providers.</p>
                </div>

                <fieldset class="component-group-list">
                    <div class="field-pair">
                        <label for="torrentrss_string">
                            <span class="component-title">Select provider:</span>
                            <span class="component-desc">
                            <input type="hidden" name="torrentrss_string" id="torrentrss_string" />
                                <select id="editATorrentRssProvider" class="form-control input-sm">
                                    <option value="addTorrentRss">-- add new provider --</option>
                                </select>
                            </span>
                        </label>
                    </div>

                    <div class="torrentRssProviderDiv" id="addTorrentRss">
                        <div class="field-pair">
                            <label for="torrentrss_name">
                                <span class="component-title">Provider name:</span>
                                <input type="text" id="torrentrss_name" class="form-control input-sm input200" />
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="torrentrss_url">
                                <span class="component-title">RSS URL:</span>
                                <input type="text" id="torrentrss_url" class="form-control input-sm input350" />
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="torrentrss_cookies">
                                <span class="component-title">Cookies:</span>
                                <input type="text" id="torrentrss_cookies" class="form-control input-sm input350" />
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc">eg. uid=xx;pass=yy</span>
                            </label>
                        </div>
                        <div class="field-pair">
                            <label for="torrentrss_titleTAG">
                                <span class="component-title">Search element:</span>
                                <input type="text" id="torrentrss_titleTAG" class="form-control input-sm input200" value="title"/>
                            </label>
                            <label>
                                <span class="component-title">&nbsp;</span>
                                <span class="component-desc">eg: title</span>
                            </label>
                        </div>
                        <div id="torrentrss_add_div">
                            <input type="button" class="btn torrentrss_save" id="torrentrss_add" value="Add" />
                        </div>
                        <div id="torrentrss_update_div" style="display: none;">
                            <input type="button" class="btn btn-danger torrentrss_delete" id="torrentrss_delete" value="Delete" />
                        </div>
                    </div>
                </fieldset>
            </div><!-- /component-group4 //-->
            % endif

            <br/><input type="submit" class="btn config_submitter_refresh" value="Save Changes" /><br/>

            </div><!-- /config-components //-->

        </form>
    </div>
</div>

<script type="text/javascript" charset="utf-8">
<!--
    jQuery('#config-components').tabs();
//-->
</script>
% include file=os.path.join(sickbeard.PROG_DIR, "gui/slick/interfaces/default/inc_bottom.mako")
