drop temporary table if exists t1, t2;

create temporary table if not exists t1 (select pp.did, SUBSTRING(pp.configuration, POSITION('\"nid\"' IN pp.configuration) + 11, 6) as pane_nid from panels_pane as pp 
where pp.type='node');

create temporary table if not exists t2 (select distinct t1.did, t1.pane_nid from t1
LEFT join node as n on t1.pane_nid=n.nid
where concat('', t1.pane_nid * 1) = t1.pane_nid
and (n.type= "type_1" or n.type = "type_2")
and n.nid != xxxxxx);

select distinct pe.entity_id from panelizer_entity as pe 
left join t2 on t2.did=pe.did
where t2.did is not null