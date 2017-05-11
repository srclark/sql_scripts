drop temporary table if exists t1, t2;

# Select all the used responsive landing pages with panes in them
create temporary table if not exists t1 (select n.nid, nh.vid, pe.did from node as n
left join workbench_moderation_node_history as nh on nh.nid=n.nid
left join panelizer_entity as pe on pe.entity_id=n.nid and pe.revision_id=nh.vid
where n.type='responsive_landing_page'
and (nh.published=1 || nh.is_current = 1)
and pe.did is not null
order by pe.did);

# Beans that are in use
create temporary table if not exists t2 (select distinct b.* from t1
left join panels_pane as pp on pp.did=t1.did
left join bean as b on b.delta=REPLACE(pp.subtype, 'bean-', '')
where pp.type='block'
and b.bid is not null
order by bid);

# Beans not in use
select * from bean as b
left join t2 on t2.bid=b.bid
where t2.bid is null
and b.type = "text_only"