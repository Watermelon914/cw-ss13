import { useBackend, useLocalState } from '../backend';
import { Stack, Section, Tabs, Input, Button, Box, Tooltip } from '../components';
import { Window } from '../layouts';
import { classes } from "common/react";

export const Pointshop = (props, context) => {
  const { data } = useBackend(context);
  const { theme } = data;
  return (
    <Window
      width={500}
      height={400}
      theme={theme}
    >
      <Window.Content>
        <GeneralPanel />
      </Window.Content>
    </Window>
  );
};

const GeneralPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { products, points, currency } = data;

  const [currentSearch, setSearch]
    = useLocalState(context, "current_search", "");

  const [selectedProduct, setSelectedProduct]
    = useLocalState(context, "selected_product", null);

  const categories = [];
  for (let i = 0; i < products.length; i++) {
    let data = products[i];
    if (categories.includes(data.category)) continue;

    categories.push(data.category);
  }

  const [currentCategory, setCategory]
    = useLocalState(context, "current_category", categories[0]);

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Tabs>
                {categories.map(val => (
                  <Tabs.Tab
                    pl={1}
                    pr={1}
                    selected={val === currentCategory}
                    onClick={() => {
                      setSearch("");
                      setCategory(val);
                    }}
                    key={val}
                  >
                    {val}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Box textAlign="center" py={1} mr={1}>
                {points} {currency}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Input
            fluid
            value={currentSearch}
            placeholder="Search for a product"
            onInput={(e, value) => setSearch(value.toLowerCase())}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Section
            fill
            scrollable
            onComponentDidMount={node => node.focus()}
          >
            <Tabs vertical fluid>
              {products.map(val => {
                if (!val.name.toLowerCase().match(currentSearch)) {
                  return;
                } else if (val.category !== currentCategory) {
                  return;
                }
                return (
                  <Tabs.Tab
                    key={val.index}
                    lineHeight="4em"
                    selected={selectedProduct === val.index}
                    onClick={() => setSelectedProduct(val.index)}
                    color={points < val.cost? "red" : "white"}
                  >
                    <Stack align="center">
                      <Stack.Item>
                        <span
                          className={classes([
                            "pointshop32x32",
                            val.image,
                            "Pointshop__ProductIcon",
                          ])}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Box>
                          {val.name}
                        </Box>
                      </Stack.Item>
                      <Stack.Divider />
                      <Stack.Item mr={1}>
                        <Box
                          textAlign="right"
                          color={points < val.cost? "red" : "white"}
                        >
                          {val.cost} {currency}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Tabs.Tab>
                );
              })}
            </Tabs>
          </Section>
        </Stack.Item>
        {!!selectedProduct && (
          <>
            <Stack.Item>
              <Box
                color="grey"
                fontFamily="Verdana"
              >
                {products[selectedProduct-1].desc}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Purchase"
                color={points < products[selectedProduct-1].cost? "bad" : "good"}
                fluid
                textAlign="center"
                onClick={() => act("purchase", { index_to_purchase: selectedProduct })}
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};
