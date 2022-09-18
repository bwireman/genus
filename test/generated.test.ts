import { apply_example, new_example, build_example } from "../types/Example";
import { apply_e, new_e, build_e } from "../types/E";
import { list_e, get_e, post_e, put_e } from "../types/rest/E_rest";
import { apply_f, new_f, build_f } from "../types/F";
import { list_f, get_f, post_f, put_f } from "../types/rest/F_rest";
import { apply_identifier, new_identifier, build_identifier } from "../types/Identifier";

const default_example = {
    a: "Hello",
    b: false,
    c: [],
    d: [],
    e: undefined,
    f: undefined,
    g: "blue",
    h: undefined,
    i: 1,
    j: "blue",
    k: undefined,
    l: 2.22,
    m: undefined
};

const default_e = {
    a: undefined,
    b: undefined,
    c: undefined,
    d: undefined,
    fizz: "fizz"
};

const default_f = {
    a: undefined,
    b: undefined,
    c: 1,
};

const default_identifier = {
    id: undefined,
};

test('Generated Example.ts', () => {
    expect(build_example({ j: "blue", l: 2.22 })).toStrictEqual(default_example);
    expect(new_example("blue", 2.22)).toStrictEqual(default_example);
    expect(apply_example(default_example)).toStrictEqual(default_example);
});

test('Generated E.ts', () => {
    expect(build_e({})).toStrictEqual(default_e);
    expect(new_e()).toStrictEqual(default_e);
    expect(apply_e(default_e)).toStrictEqual(default_e);
});

test('Generated rest_e.ts', async () => {
    let expected_e = build_e({ a: "A", b: true, c: 1 });

    expect(await get_e(1)).toStrictEqual(expected_e);
    expect(await post_e(expected_e)).toStrictEqual(expected_e);
    expect(await put_e(expected_e)).toStrictEqual(expected_e);
    expect((await list_e(new Map()))[0]).toStrictEqual(expected_e);
});

test('Generated F.ts', async () => {
    expect(build_f({})).toStrictEqual(default_f);
    expect(new_f()).toStrictEqual(default_f);
    expect(apply_f(default_f)).toStrictEqual(default_f);
});

test('Generated rest_f.ts', async () => {
    const handle = jest.fn();
    await get_f(1, handle);
    await post_f({}, handle);
    await put_f({}, handle);
    await list_f(new Map(), handle);

    expect(handle.mock.calls.length).toBe(4);
});

test('Generated Identifier.ts', () => {
    expect(build_identifier({})).toStrictEqual(default_identifier);
    expect(new_identifier()).toStrictEqual(default_identifier);
    expect(apply_identifier(default_identifier)).toStrictEqual(default_identifier);
});
