import * as fs from "fs";
import * as path from "path";
import { createClient } from "@clickhouse/client";


const CLICKHOUSE_URL = process.env.CLICKHOUSE_URL;
const CLICKHOUSE_USER = process.env.CLICKHOUSE_USER;
const CLICKHOUSE_PASSWORD = process.env.CLICKHOUSE_PASSWORD;

if (!CLICKHOUSE_URL || !CLICKHOUSE_USER || !CLICKHOUSE_PASSWORD) {
  console.error("Environment variables CLICKHOUSE_URL, CLICKHOUSE_USER, and CLICKHOUSE_PASSWORD must be set");
  process.exit(1);
}

const client = createClient({
  url: CLICKHOUSE_URL,
  username: CLICKHOUSE_USER,
  password: CLICKHOUSE_PASSWORD,
});

interface Query {
  name: string;
  group: string;
  comment?: string;
  query: string;
  chart: string;
  format?: boolean;
}

const loadQueries = async () => {
  const filePath = path.resolve(__dirname, "queries.json");
  
  fs.readFile(filePath, "utf8", async (err, data) => {
    if (err) {
      console.error("Error reading file:", err);
      return;
    }
    
    try {
      const queries = JSON.parse(data) as { queries: Query[] };

      // Create the temporary table
      await client.exec({
        query: `
          CREATE TABLE IF NOT EXISTS default.queries_temp
          (
            id FixedString(26) MATERIALIZED generateULID(),
            name String,
            group String,
            query String,
            chart String DEFAULT '{"type":"line"}',
            format Bool
          )
          ENGINE = MergeTree()
          ORDER BY id
        `,
      });
      console.log("Created temporary table queries_temp");

      // Insert data into the temporary table
      for (const query of queries.queries) {
        await client.insert({
          table: "default.queries_temp",
          values: [
            {
              name: query.name,
              group: query.group,
              query: query.comment ? `--${query.comment}\n${query.query}` : query.query,
              chart: query.chart,
              format: query.format ? true: false
            },
          ],
          format: 'JSONEachRow',
        });
        console.log(`Inserted query: ${query.name} into queries_temp`);
      }

      // Swap tables
      await client.exec({ query: `EXCHANGE TABLES default.queries_temp AND default.queries` });
      console.log("Swapped tables queries_temp and queries");

      // Drop the temporary table
      await client.exec({ query: `DROP TABLE default.queries_temp` });
      console.log("Dropped temporary table queries_temp");
      
    } catch (error: unknown) {
        console.log(error)
    } finally {
      await client.close();
    }
  });
};

loadQueries();
