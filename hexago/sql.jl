using SQLite

dbname="dev.sqlite"
db = SQLite.DB(dbname)
SQLite.query(db, "CREATE TABLE ais (name STRING, net STRING, points REAL)")

function addaifromfile(fn::AbstractString,db=db)
	net=readall(fn)
	SQLite.query(db, "INSERT INTO ais VALUES (?1, ?3, ?2)", [fn,net,0])
end
