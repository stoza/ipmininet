hostname ${node.name}
password ${node.password}

% if node.bgpd.logfile:
log file ${node.bgpd.logfile}
% endif

% for section in node.bgpd.debug:
debug bgp section
% endfor

router bgp ${node.bgpd.asn}
    bgp router-id ${node.bgpd.routerid}
    bgp bestpath compare-routerid
% for n in node.bgpd.neighbors:
    no auto-summary
    neighbor ${n.peer} remote-as ${n.asn}
    neighbor ${n.peer} port ${n.port}
    neighbor ${n.peer} description ${n.description}
    % if n.ebgp_multihop:
    neighbor ${n.peer} ebgp-multihop
    % endif
    % if n.peer_is_active:
    ! In order to avoid simultaneous openings of the BGP session,
    ! one of the peers has to actively establish the session
    ! and the other one has to wait.
    ! The following line makes this router passive for this BGP peering
    ! because the peer is active.
    ! Note that BGP would work without this line
    ! but additional traffic would be generated (see Section 6.8 RFC4271).
    neighbor ${n.peer} passive
    % endif
    <%block name="neighbor"/>
% endfor
% for af in node.bgpd.address_families:
    % if af.name != 'ipv4':
    address-family ${af.name}
    % endif
    % for net in af.networks:
    network ${net.with_prefixlen}
    % endfor
    % for r in af.redistribute:
    redistribute ${r}
    % endfor
    % for n in af.neighbors:
    neighbor ${n.peer} activate
        % if n.nh_self:
    neighbor ${n.peer} ${n.nh_self}
        % endif
    % endfor
    % if af.name != 'ipv4':
    exit-address-family
    % endif
    !
% endfor
<%block name="router"/>
!
