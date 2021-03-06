-- drop old trigger
DROP TRIGGER test_log_chg ON test;

-- create demo table
DROP TABLE test;
CREATE TABLE test (
  id                    INT                 NOT NULL
                                            PRIMARY KEY,
  name                  VARCHAR(20)         NOT NULL
);

-- create the table without data from demo table
DROP TABLE test_log;
SELECT * INTO test_log FROM test LIMIT 0;
ALTER TABLE test_log ADD COLUMN trigger_mode VARCHAR(10);
ALTER TABLE test_log ADD COLUMN trigger_tuple VARCHAR(5);
ALTER TABLE test_log ADD COLUMN trigger_changed TIMESTAMPTZ;
ALTER TABLE test_log ADD COLUMN trigger_id BIGINT;
ALTER TABLE test_log ALTER COLUMN trigger_id SET DEFAULT NEXTVAL('test_log_id');
CREATE SEQUENCE test_log_id;
SELECT SETVAL('test_log_id', 1, FALSE);

-- create trigger
CREATE TRIGGER test_log_chg AFTER UPDATE OR INSERT OR DELETE ON test FOR EACH ROW
               EXECUTE PROCEDURE table_log();

-- test trigger
INSERT INTO test VALUES (1, 'name');
SELECT * FROM test;
SELECT * FROM test_log;
UPDATE test SET name='other name' WHERE id=1;
SELECT * FROM test;
SELECT * FROM test_log;

-- create restore table
SELECT table_log_restore_table('test', 'id', 'test_log', 'test_log_id', 'test_recover', NOW());
SELECT * FROM test_recover;
