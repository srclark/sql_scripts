drop temporary table if exists t1, t2;

# Select all the used responsive landing pages with panes in them
drop temporary table if exists published_content, published_panelizer_nodes, panel_info, minis;

/* Get the current published version of the workbench moderated content */
create temporary table if not exists published_content (
select nh.nid, nh.vid from workbench_moderation_node_history as nh
where nh.published = 1);

/* Get the current published version of nodes that use panelizer */
create temporary table if not exists published_panelizer_nodes (
select pe.entity_id, pe.did from panelizer_entity as pe
left join published_content as pc on (pc.nid=pe.entity_id and pc.vid=pe.revision_id)
where pc.nid is not null);

/* Get the panes in the panelizer content */
create temporary table if not exists panel_info ( 
select ppn.*, pp.panel, pp.type, pp.subtype, pp.shown from panels_pane as pp 
left join published_panelizer_nodes as ppn on ppn.did=pp.did
where ppn.entity_id is not null
and pp.type='panels_mini'
);

/* Get all the panes with mini-panels */
create temporary table if not exists minis ( 
select pi.entity_id, pm.name, pm.did, pm.admin_title from panel_info as pi
left join panels_mini as pm on pm.name=pi.subtype
where pm.name is not null
order by pi.entity_id
);

/* Get the contents of the mini-panels in published panelizer pages */
create temporary table if not exists t3 (select distinct m.entity_id from panels_pane as pp
left join minis as m on m.did=pp.did
left join bean as b on b.delta=REPLACE(pp.subtype, 'bean-', '')
where t3.name is not null
and b.type="text_only"
order by m.entity_id);

/* Make the data usuable by giving an alias */
select CONCAT('https://example.com/', l.prefix, '/', COALESCE(ua.alias, CONCAT('node/', t3.entity_id))) as alias, t3.* from t3 
left join url_alias as ua on REPLACE(ua.source, 'node/', '')=t3.entity_id
left join node as n on n.nid=t3.entity_id
left join languages as l on l.language=n.language