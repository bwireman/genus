import { apply_example, new_example } from "../types/Example";
import { apply_e, new_e } from "../types/E";
import { apply_f, new_f } from "../types/F";


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
    j: undefined,
    k: undefined,
    l: 3.14,
};

const default_e = {
    a: undefined,
    b: undefined,
    c: undefined,
    d: undefined,
};

const default_f = {
    a: undefined,
    b: undefined,
    c: undefined,
};

test('Generated Example.ts', () => {
    expect(new_example()).toStrictEqual(default_example);
    expect(apply_example(default_example)).toStrictEqual(default_example);
});

test('Generated E.ts', () => {
    expect(new_e()).toStrictEqual(default_e);
    expect(apply_e(default_e)).toStrictEqual(default_e);
});

test('Generated F.ts', () => {
    expect(new_f()).toStrictEqual(default_f);
    expect(apply_f(default_f)).toStrictEqual(default_f);
});