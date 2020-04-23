# transfORM

mini ORM for Delphi

The library is an experiment with RTTI and generics to gain simple, object-oriented access to data from a relational database.

Configuration consists of passing the connection to the database, either by a configured TFDConnection, or by a registered FireDAC Connection Definition Name.

```
var
  ORM : TransfORM;
begin  
  ORM := TransfORM.Create('SERVICE_DB_CONNDEF');
```

The second step is to define the interface according to the formula:

```
I[TableName] = interface(ItransfORMEntity)  
  function [ColumnNameA] : TransfORMField;  
  function [ColumnNameB] : TransfORMField;  
  function [ColumnNameC] : TransfORMField;  
  [...]  
end;  
```

...where TableName is the name of the table in the database and ColumnNameA, ColumnNameB etc. are the names of the columns you want to access in the given interface (they do not have to be all).

The last step is to obtain an interface instance containing the data of a specific row from the table. To do this, we call the GetInstance<Inteface> method, giving the value of the primary key.

```  
var
  Entity : I[TableName];
  PKValue : Integer;
begin
  PKValue := 100; //primary key value
  Entity := ORM.GetInstance<I[TableName]>(PKValue);
```

Current limitations:
- keys can only be simple and of an integer type
- cannot be downloaded other than via a primary key


The library uses: Spring4D, FireDAC
