drop temporary table if exists moderated_nodes, first_last_published, current_published_rev, unmoderated_nodes, unmoderated_published_dates;

/* Node types that use workbench moderation */
create temporary table if not exists moderated_nodes (select distinct n.type from workbench_moderation_node_history as nh
left join node as n on nh.nid=n.nid
where n.type is not null);

/* First and last published date */
create temporary table if not exists first_last_published (select nh.nid, MIN(nh.stamp) as first, MAX(nh.stamp) as last from workbench_moderation_node_history as nh
where state='published'
and nh.nid > 0
group by nh.nid);

/* Current and Published dates */
create temporary table is not exists current_published_rev (select distinct nh.nid, nh.stamp, nh.current as current_rev, nh.published as published_rev from workbench_moderation_node_history as nh
where nh.current=1 OR nh.publishe=1);

/* Unmoderated node types */
create temporary table if not exists unmoderated_nodes (select nt.type from node_type as nt 
left join moderated_nodes as mn on mn.type=nt.type
where mn.type is null);

/* Find first and last published date of unmoderated content */
create temporary table if not exists unmoderated_published_dates (select nr.nid, min(nr.timestamp) as first, max(nr.timestamp) as last from node_revision as nr 
left join node as n on n.nid=nr.nid
left join unmoderated_nodes as un on un.type=n.type
where un.type is not null
and nr.status=1
group by nr.nid);
