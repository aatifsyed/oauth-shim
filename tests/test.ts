import { expect, test, type Page } from '@playwright/test';


test('no params has website description', async ({ page }) => {
	await page.goto('/');
	await expect(page.getByText("A simple redirect URL for OAuth applications")).toBeVisible();
});

test('code param is copied', async ({ page }) => {
	await page.goto("/?code=foo");
	await page.getByRole("button").click();

	let text = await page.evaluate("navigator.clipboard.readText()");
	expect(text).toContain('{"code":"foo"}');
})

test('code and state params are copied', async ({ page }) => {
	await page.goto("/?code=foo&state=bar");
	await page.getByRole("button").click();

	let text = await page.evaluate("navigator.clipboard.readText()");
	expect(text).toContain('{"code":"foo","state":"bar"}');
})

test('error has a heading', async ({ page }) => {
	await page.goto("/?error=foo");
	await expect(page.getByRole("heading", { name: "Authorization Error" })).toBeVisible();
})
