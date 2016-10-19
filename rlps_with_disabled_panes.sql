drop temporary table if exists t1, t2;

# Select all the used responsive landing pages with panes in them
create temporary table if not exists t1 (select n.nid, n.language, nh.vid, pe.did from node as n
left join workbench_moderation_node_history as nh on nh.nid=n.nid
left join panelizer_entity as pe on pe.entity_id=n.nid and pe.revision_id=nh.vid
where n.type='responsive_landing_page'
and (nh.published=1 || nh.current = 1)
and pe.did is not null
order by pe.did);

# Responsive landing page  with disabled panes
create temporary table if not exists t2 (select distinct t1.nid, t1.language from t1
left join panels_pane as pp on pp.did=t1.did
where pp.type='block'
and pp.shown=0
order by bid);

# Aliases
select CONCAT('https://example.com/', l.prefix, '/', COALESCE(ua.alias, CONCAT('node/', t2.nid))) as alias,  t2.* from t2 
left join url_alias as ua on REPLACE(ua.source, 'node/', '')=t2.nid
left join languages as l on l.language=t2.language
